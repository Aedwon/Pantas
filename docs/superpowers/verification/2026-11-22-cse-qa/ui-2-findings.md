# ui-2 findings: CSE, Free and Pro, phone and wide web (sign-in, onboarding, Home, Progress, Profile, Settings, paywall, mocks, shell, states)

Policy commit used: origin/main 78a7d90a6350879da9dd0952f8c5f51c0a432e3a (AGENTS.md, process-improvement.md rules 1 to 4). Code: this worktree (qa/cse-release-r1). Read only; nothing built or run.
Section order: lead findings (G4 beta surfaces, P10 mock figures), then the four slice reports (A sign-in/onboarding/shell/states, B Home/Progress/Profile, C Settings/paywall/checkout, D mocks), each with its own button inventory and figure list.

## LEAD: P10, Subprofessional section counts (A17 placeholder shown as if official)

### Mock setup: Subprofessional even-split counts printed as plain facts, no caveat
- Severity: major
- Evidence: content/mock/cse-sub.yaml:12-24 (sourceNote: "an even division chosen here until a taker of this level supplies the real counts"); content/mock/cse-sub.yaml name "CSE Subprofessional Practice Paper" (no "Pantas practice exam, not the official format" label); lib/features/mock_exam/domain/mock_title.dart:13-21 (label shows only if the blueprint name contains it, so CSE shows none); lib/features/mock_exam/presentation/pages/mock_setup_page.dart:146 and :427 ("$plannedTotal total items · ${_duration}"), :180 and :320 ("The real exam also has ${unscoredItems} personal-information items..."), _SetupTable :485-545 (prints bare "$value"; the placeholder marker only applies when the blueprint figure carries isPlaceholder, and the YAML sets none); docs/superpowers/decisions/2026-11-17-fable-backlog-rulings.md:96 (A17 Do later, trigger "a Subprofessional taker reports the counts"); docs/superpowers/decisions/2026-10-19-pwa-launch-log.md:1055 (Aedwon "proceed": "Subprofessional uses an even split until a taker recalls its counts") and :4038 ("Students must see 'Pantas practice exam, not the official format'", stated for DCAT and USTET, "Pantas-set values are marked as such")
- Gap: The student sees, with no marker of any kind: title "CSE Subprofessional simulation"; line "145 total items · 2 hr 40 min"; table rows (column "Items") Verbal Ability 36, Numerical Ability 36, Clerical Ability 36, General Information 37; the rule line "This paper runs as one block. You can move around the whole paper and submit when you're done."; and "The real exam also has 20 personal-information items. They are not scored, so this mock leaves them out." The split 36/36/36/37 is Pantas's own division (YAML says so), the CSC publishes no per-area counts, and the 145 and the 20 rest on "a 2020 CSC advisory ... whether that still holds is unconfirmed". The sentence "The real exam also has 20 ..." states an unconfirmed figure as a fact about the real exam. The page reads as the official layout. Under AGENTS.md "Never invent a figure" the four section counts are inferred by the project, which "may not be printed as a figure". A17 defers replacing them; it does not rule that they may be shown unlabeled. Only the label rule (Nov 20) covers this, and CSE Sub does not carry the label.
- Platforms: both; Free and Pro
- Fix idea: add "Pantas practice exam, not the official format" to the Sub blueprint name (the existing opt-in), and soften "The real exam also has 20" to "reported"; or drop the per-section Items column for Sub until a taker reports counts.

### Mock setup: Professional counts are one examinee's recollection, and contradict the Sub note's own CSC advisory
- Severity: major
- Evidence: content/mock/cse-pro.yaml:12-24 ("recollection of an examinee ... relayed by Aedwon on 19 October 2026 (General Information 20, Verbal Ability 55, Analytical Ability 35, Numerical Ability 45; 155 test items) ... 15 personal-information items"); content/mock/cse-sub.yaml:12-17 ("2020 CSC advisory (150 test items plus 20 descriptive questionnaire items for the Professional level, 145 plus 20 for the Subprofessional level)"); mock_setup_page.dart:146, :180, :320, _SetupTable
- Gap: The Professional setup screen prints "155 total items · 3 hr 10 min", rows 20/55/35/45 and "The real exam also has 15 personal-information items". Two sources the project holds disagree on this level: 155 + 15 (one examinee) versus 150 + 20 (the 2020 advisory the Sub note cites). The screen shows the 155 and 15 with no "reported" marker. Aedwon approved "marked as reported" (launch log 1050-1055) but no marker reaches the screen: `source: reported` and `sourceNote` are stored (lib/core/content/repos/mock_blueprint_repo.dart:32-33) and never read by any presentation file (grep in lib/features/mock_exam finds no use).
- Platforms: both; Free and Pro
- Fix idea: show the "reported" status the approved decision asked for, or reconcile 155/15 with 150/20 before launch.

## LEAD: G4, beta-only surfaces a public student could see

Context for all rows: the web gate is compiled in (`BETA_GATE=true`, lib/app/beta_gate.dart:36-40; the gate "has no end date", lines 13-19). Today (Nov 22) prod web is built with it (launch log 2564, 2673, 2959). Until a build turns it off, a public student on web cannot enter at all: any account not on `betaApplications` lands on the beta sign-in screen below. Native builds have no gate, but the beta checks still run there (lib/core/auth/beta_access.dart:89-96), so a non-listed native user sees none of the tester rows. Rows below marked "tester only" show only to accounts selected on the beta list, and (per the code comment at lib/features/beta_feedback/application/beta_feedback_providers.dart:23-24) stay visible "including after the beta week".

| # | file:line | text | who sees it | verdict |
|---|---|---|---|---|
| 1 | lib/app/beta_gate.dart:36-40, 63-80, 83-136 | whole gate: non-listed user redirected to /beta | every public web visitor while BETA_GATE=true | REMOVE for public: build web without BETA_GATE (nothing in the repo or in docs/deploy-prod.md says who flips it or when; deploy-prod.md never mentions BETA_GATE and still says the beta runs Nov 9 to 15 at lines 1, 8, 42) |
| 2 | lib/app/sign_in/email_sign_in_page.dart:662-681 | "BETA" mark beside "Welcome to Pantas" | public web visitor (sign-in screen) | REMOVE (follows BETA_GATE: `beta:` is true only on the gate page) |
| 3 | email_sign_in_page.dart:688-690 | "Sign in with the email you applied with." (public version reads "Sign in with your email.") | same | REWORD (goes with the gate) |
| 4 | email_sign_in_page.dart:960 | "This email isn't on the beta list" | any non-listed signed-in user on web | REMOVE; this screen is what a public student meets first if the gate stays |
| 5 | email_sign_in_page.dart:932-942 | "You're signed in. If you applied with a different email, sign in with that one." | same | REMOVE with row 4 |
| 6 | email_sign_in_page.dart:987 | "Selected testers get an email from Pantas." | same | REMOVE with row 4 |
| 7 | lib/app/beta_gate.dart:111 | "We couldn't check beta access. Try again." | web, when the beta check errors | REMOVE with the gate |
| 8 | lib/app/beta_waiting_page.dart:257 | "The beta starts Nov 9" | nobody now: the server returns waitUntil only before Nov 9 (functions/src/betaAccess.ts:41-42) | REMOVE dead page (also tiles days/hours/min :478-487) |
| 9 | beta_waiting_page.dart:302, 347 | link "Read the tester guide" -> https://www.pantas.study/beta/guide | nobody now (same page) | REMOVE |
| 10 | lib/features/home/application/home_notices.dart:97-190 (titles at 128-135, 166, 176, 180, 185) | "You earned 1 year of Pro", "N of 5 beta days. Ends Nov 22.", "A day counts when you finish your whole Today plan. Reach 5 by Nov 22 and send the exit survey to earn 1 year of Pro.", "Send the exit survey by Nov 23", "It has 7 short questions. ...", buttons "Take the Survey", "See Your Days", "See Your Reward" | tester only. Window ends at survey close Nov 24 00:00 PHT (home_notices.dart:131-134 returns null after; reward on server SURVEY_CLOSES_AT functions/src/betaReward.ts:4). The "You earned" notice has no end date until activated (activation deadline Jan 1, 2028, betaReward.ts:5) | REMOVE for the public, KEEP for earners (they were promised the year). Needs a rule for how long the "earned" notice stays |
| 11 | lib/features/home/presentation/widgets/home_notice_strip.dart:158, 208, 251 | beta notice kind routing and icon | same | follows row 10 |
| 12 | lib/features/settings/presentation/settings_home_page.dart:44-60, 162-180, 288-296; settings_pane_page.dart:486-508 (BETA mark at 494); lib/app/routes/settings_routes_native.dart:300 | row "Feedback" with raised "BETA" mark; row value "N of 5 days" (settings_home_page.dart:36-40); screen semantics label "Feedback, beta" (:164) | tester only, also after the beta week | REWORD or REMOVE the BETA mark for the public; Aedwon asked for "Feedback (Beta)" naming, so this needs his call. A feedback channel for all users may be wanted; needs a board |
| 13 | lib/features/settings/presentation/widgets/beta_pro_row.dart:67, 80, 97 | switch "Beta: Pro Features"; "Turning On…" | any account for which getWebEntitlement returns betaProUntil, only before Nov 23 00:00 PHT. The server throws "This account is not on the beta list." for a non-tester (functions/src/betaPro.ts:41-43), so a non-listed student could see a switch that always fails (note: the row's visibility is the server reply, not the beta list; the server returns betaProUntil to every caller, functions/src/webEntitlement.ts:20) | REMOVE after Nov 23 (it disappears by itself: see env section). Before Nov 23, MAJOR if a non-listed student can see it |
| 14 | beta_pro_row.dart:127 | "Pro features are on for the beta, until Nov 23." | tester with switch on | hides itself at the cutoff; REMOVE the code after |
| 15 | lib/features/settings/application/settings_providers.dart:229 | Pro row value "Pro" while the beta switch is on | same | follows row 13 |
| 16 | lib/features/beta_feedback/presentation/*.dart (feedback_page.dart:59 "Count 5 days from Nov 9 to 22 and send the exit survey to earn 1 year of Pro."; days_card.dart:148, 405-438 "Exit Survey", "Opens/Until/Sent/Closed"; exit_survey_page.dart:240 "4. Will you keep using Pantas after the beta?"; reward_card.dart:125-132, 163-250 "Thank you for testing Pantas.", "Activate 1 Year of Pro", "After <date>, your account goes back to Free."; compose_card.dart:211 "What worked, what broke, what you would change"; survey_sent.dart:138 "Thank you for helping shape Pantas.") | the whole Feedback feature, routes /settings/beta-feedback, /sent/:id, /survey | tester only | KEEP the reward card for earners; REMOVE or generalize the rest for the public; needs a board for any public feedback page |
| 17 | lib/core/ui/components/... none; lib/features/legal/domain/legal_document.dart:330 | Terms: "as a trial, a beta period or a prize, at its choice" | every student who opens Terms | generic and harmless; KEEP |
| 18 | web/index.html:48 and web/og-image.png | og:image:alt "The Pantas logo with the words Pantas beta"; the image itself shows "Pantas" with a teal "BETA" mark | every link preview of app.pantas.study | REMOVE: reissue the image and alt text without BETA |
| 19 | lib/core/telemetry/screen_ids.dart:54-56, lib/app/web_route_shell.dart:60, lib/core/platform/callable_options.dart:12-30 | route names and callables with "beta" | not user-facing text | no action |

### Functions behavior after Nov 23 (BETA_PRO_UNTIL, BETA_CUTOFF)
- functions/src/betaPro.ts:16 hard-codes `BETA_CUTOFF = 2026-11-23T00:00:00+08:00`. `betaProUntil(at)` (:18-22) returns null once `at >= min(BETA_PRO_UNTIL, BETA_CUTOFF)` and also when the variable is missing or invalid. `setBetaPro` then throws "The beta has ended." (:46-47). The env value can never extend the window (comment at :17); a longer beta needs a code change and a deploy.
- functions/.env.pantas-prod:2 and functions/.env.pantas-staging:2 both hold `BETA_PRO_UNTIL=2026-11-23T00:00:00+08:00`. No change needed for the cutoff itself.
- Client: lib/features/paywall/application/beta_pro_provider.dart:42-70 hides the Settings switch and note when `betaProUntil` is null or past, and a timer removes it at the cutoff even with Settings open (:23-24, 57-62), then calls restorePurchases (:73-78). Existing beta grants carry `endsAt = until` (betaPro.ts:55), so they lapse by themselves; the Pro row then reads "Free" (settings_providers.dart:227-236).
- Still live after Nov 23: `getBetaAccess` (betaAccess.ts) and the whole `betaApplications` allow-list gate; `BETA_START` waiting logic (dead after Nov 9); the survey until `SURVEY_CLOSES_AT` Nov 24 00:00 PHT; reward activation until Jan 1, 2028 (betaReward.ts:5). Home notice rule: lines above.
- Related launch limit (not beta text): sign-in code mail is capped at `SIGN_IN_DAILY_SEND_CAP=20` per Manila day for strangers (functions/.env.pantas-prod:11) with 40 reserved for listed testers and existing accounts (functions/src/signInCode.ts:153-175). A public launch sends far more than 20 first-time codes a day; the open bucket would refuse the 21st new student. Raise it before opening the gate.
- docs/deploy-prod.md:1, 8, 41-43 still describe a Nov 9 to 15 beta and `BETA_PRO_UNTIL=2026-11-16`: stale against the env files (a deploy from that doc would end beta Pro early; see launch log line 3748).

## LEAD: P10 summary, figures that are not measured, published or from a named algorithm
Full per-screen lists are in each slice report below. The ones that fail the rule or rest on thin ground:
- Subprofessional section counts 36/36/36/37, and the "145 total items" and "20 personal-information items" lines: Pantas-set split on an unconfirmed 2020 advisory (finding above).
- Professional section counts 20/55/35/45, "155 total items", "15 personal-information items": one examinee's recollection; the Sub note cites 150 + 20 for the same level. No "reported" marker on screen (finding above).
- "10 easy reviews" on exam day (Home, slice B): the 10 is a fixed cap with no source and nothing selects easy items.
- Tendencies "Peak hour" and the archetype cutoffs (slice B): ungated bucket accuracy and invented thresholds.
- CSE Professional overall accuracy (slice B): weighted by 5/30/35/30 area weights that Aedwon relayed on Nov 5 ("it is official because a lot of people are posting the same thing", launch log 2554); CSC publishes no weights. His ruling stands, but the on-screen figure is not published by the testing body.
- Record "N day streak" and "61% this week" (slice B): the streak is not decayed after missed days and the "this week" label can name an old week, so the printed figure is wrong by the app's own rules.
- Hard-coded "7" in every trial string, "0.1.0" version, beta dates "until Nov 23", "Nov 9 to 22" (slice C): constants, not read from the product, version or server.
- Mock results print no pass mark or band for CSE (slice D): correct under the rule.
- Everything else listed in the slice figure tables is measured, user-entered, app content, store data, or a named algorithm (FSRS, Welch, two-proportion test, streak evaluator).

## LEAD: finding 2 on my surfaces ("Part X of Y · N questions")
The label also appears on Home lesson rows (slice B finding "Home: lesson rows carry Part X of Y"). Study and lessons belong to another reviewer. What the record shows:
- Spec docs/superpowers/specs/2026-11-13-bite-sized-lessons-design.md:87 lists "Label 'Part 2 of 3 · 4 questions'" as "Yes, after a mockup"; :446-447 "Every UI row needs a visual-companion mockup ... approved by Aedwon before it is built".
- Launch log line 3248-3250: Aedwon, verbatim: "for things needing my decision, consult a fable 5.2 agent instead". Fable 5.2 ruled option (a), "Part 2 of 3 · 4 questions", and wrote "The visual-companion mockup is still required before any UI is built; a Claude worker builds it, it goes to a Fable ruling, and the manager shows it to Aedwon."
- Line 3286: the first mockup (origin/mockup/bite-sized-label, commits 3ffc2f9dd and 7e0fa87fb, not merged) "broke written rule 3 ... caught before anything was shown". Aedwon's only words there: "don't do too many at once, mind my 5-hour limits".
- Line 3490: a board "Bite-sized Lesson Labels" was ruled by Fable under his delegation.
- Aedwon's approval of the label or of a mockup of it: not found. The label shipped on a Fable ruling only.

## LEAD: finding 3 across my surfaces (summary of the four inventories)
- Boards that draw no Close or Cancel under the sheet, but the code adds one: Home Lessons, Reviews and New questions sheets (Close), Home exam date sheet (Cancel), Performance Subjects sheet (Cancel), mock Questions sheet (Close). Each adds a full-width 52 px tertiary button plus 8 px above and 34 to 54 px below, 94 to 114 px of extra sheet height (slice B, slice D).
- Boards that do draw it at 52 (L_ChangeExam2, onboarding O_Days): code matches the board, and Aedwon's complaint then needs a new board (slice A).
- Wide web: dialog and sheet Cancel and notice "Later", "Got It" are 44 high with 20 side padding where the boards draw 40 to 42 with 14 (slices A, B, C). Wide Pro-page Restore Purchases and Switch on Free the same (slice C).
- Phone Pro-page Restore Purchases: 52 px full-width text button where the board draws a 15/600 line about 24 px tall (slice C, major).

## Counts (slice findings plus lead findings)
- Blocker: 1 (conditional, beta gate on web)
- Major: 28 (A 5, B 7, C 6, D 8, lead 2)
- Minor: 82 (A 18, B 22, C 26, D 16)
- Plus the G4 table (19 rows) and the functions-after-Nov-23 notes.

---

# SLICE A: sign-in, onboarding, shell, states, dialogs and sheets
# UI inspection 2, reviewer A: sign-in, onboarding, shell, states, dialogs and sheets

Read only. Policy read from origin/main 78a7d90a6 (AGENTS.md, docs/workflow/process-improvement.md rules 1 to 4). Code root is the QA worktree (prod build 1275724943). Boards: web-design/pantas-handoff (web/project, mobile/project, web/shared/pantas.css). Nothing was built or run, so every pixel value is read from code and board source, not measured on screen.

Method notes
- The handoff export has no board for the beta sign-in, email code step, "not on the beta list" or beta waiting screens. docs/ui-audit.md (DS4 round 2) says "no board draws this page". The decision log (2026-10-19-pwa-launch-log.md line 2568) says they were drawn in a Claude Design canvas ("Pantas beta sign-in", artifact EBQopPTcLczwabNWkTSake) that is not in the export. Those screens cannot be checked against a board here.
- The handoff OB_* boards are older than several approved changes (age step "How old are you?" approved Nov 10 "A", exam date picker, "sharing usage data" copy, reminders step parked for web). Where code differs from the old board but a logged Aedwon decision covers it, it is not listed as a gap.
- Free and Pro: the only Free vs Pro difference on these surfaces is the sidebar plan line ("UPCAT · Free" style), which is not guessed while coverage is unknown (web_route_shell.dart:97-104). No other difference found.

---

### Sign-in: the beta gate puts every web visitor on a sign-in with a "not on the beta list" dead end
- Severity: blocker (conditional: only if the CSE release build keeps BETA_GATE=true)
- Evidence: lib/app/beta_gate.dart:21-27 ("The gate has no end date", Fable ruling Nov 15) and :37-40; lib/app/sign_in/email_sign_in_page.dart:960 "This email isn't on the beta list"; every prod deploy in docs/superpowers/decisions/2026-10-19-pwa-launch-log.md (lines 2564, 2673, 4052) built with BETA_GATE=true; HANDOFF.md / board OB_Welcome notes: "Sign-in happens later, from Settings, after they have used the app"
- Gap: boards and HANDOFF say Welcome has one button (Get Started) and sign-in is optional, later, from Settings (OB_SignIn, L_SignIn). Code with the gate on sends every visitor to /beta first (beta_gate.dart:85-95); a non-listed email gets the dead-end screen with only "Use a Different Email". A student who is not a beta tester cannot enter at all.
- Platforms: wide web and phone web; Free and Pro (native builds have no gate)
- Fix idea: release build must set BETA_GATE=false and the release checklist must name it; lead confirms the CSE release is not behind the gate.

### Sign-in: beta sign-in, code step, not-on-list and waiting screens have no exported board
- Severity: major
- Evidence: docs/ui-audit.md (round 2 fix list: "no board draws this page"); lib/app/sign_in/email_sign_in_page.dart:577-583 (`ds-board: wide sign-in heading column`); decision log line 2568 and 2649 name canvas EBQopPTcLczwabNWkTSake (not in web-design/pantas-handoff)
- Gap: nothing in the export to match 1:1. Values in code that cannot be verified: field 52 high, radius 14, 2 px border (sign_in_parts.dart:855); code boxes; 48 px wide display title; wide heading column 560 with a 420 form (email_sign_in_page.dart:582-584); waiting logo 104 phone / 120 wide (beta_waiting_page.dart:~246); tiles max width 300 (:285); top offset 56+56+20 (beta_waiting_page.dart:204).
- Platforms: both; Free and Pro
- Fix idea: export the beta canvas into the handoff folder, then re-check these screens. Needs a board in the export (the board exists in Claude Design).

### Sign-in: waiting screen hard-codes "The beta starts Nov 9" and mixes tile labels
- Severity: minor
- Evidence: lib/app/beta_waiting_page.dart:257 `'The beta starts Nov 9'`; :487 `(countdown.minutesText, 'min', ...)` next to `'day'/'days'` and `'hour'/'hours'` (:481-486); countdown comes from `until` (server waitUntil) at :71-79
- Gap: the countdown reads the real server time but the title is a literal date. If waitUntil differs from Nov 9 the title is wrong. Labels are "days", "hours" but "min" (abbreviated, never plural). No board or spec asks for either wording (none found).
- Platforms: both; Free and Pro
- Fix idea: format the title from `until` in Manila time, and use "minutes" or abbreviate all three.

### Sign-in: gate error and loading states are raw, off-system
- Severity: minor
- Evidence: lib/app/beta_gate.dart:96-101 (loading: `SkeletonBlock(width: 240, height: 32, radius: 0)` and `320 x 48`, radius 0); :109-119 (error: plain `Text("We couldn't check beta access. Try again.")`, `PantasButton(label: 'Try again')`, raw `Text('support@pantas.study')`); L_Rules.dc.html ("Grey shapes where the content will be"); HANDOFF.md ("Labels are Title Case"); skeleton.dart:194-212 (default radius 5 for lines, 12 for blocks); state_view.dart:46 (`Try Again`)
- Gap: loading shows square blocks sized to no real layout (the next screen has a logo, title, field or tiles). Error label is "Try again" (sentence case) where the rest of the app uses "Try Again"; the support address is unstyled and not tappable, while SupportLine elsewhere is a teal tappable link (sign_in_parts.dart:~840). No board (none found).
- Platforms: both; Free and Pro
- Fix idea: use StateView and SupportLine for the error; drop or reshape the loading skeleton. Needs a board for the gate states.

### Sign-in: sign-in screens switch to the laptop layout at 720, the app at 1024
- Severity: minor
- Evidence: lib/app/sign_in/sign_in_parts.dart:27 `signInWideFrom = 720.0`; lib/core/ui/web/web_layout.dart:1-20 (phone under 600, tablet portrait 600 to 1023 uses TabBar and phone layout, laptop from 1024)
- Gap: between 720 and 1023 px (iPad portrait, small desktop window) the sign-in and waiting screens draw the laptop board (48 px display title, 420 form) but onboarding and the app next to it draw the phone layout. DS TabletLayout (D136) says laptop starts at 1024.
- Platforms: wide web (720 to 1023); Free and Pro
- Fix idea: use `context.wideWeb` for the sign-in screens, or record 720 as a ruling.

### Sign-in: wide sign-in buttons are full width
- Severity: minor
- Evidence: lib/app/sign_in/sign_in_parts.dart:649-650 (`SignInButton` `width: double.infinity`, height 52 on every width) and :703-704 (`SignInTextButton` `width: double.infinity`, height 44); used at email_sign_in_page.dart:775, 797, 823, 829, 868, 896; HANDOFF.md hard rule "No full-width buttons on wide screens. Buttons are natural width."
- Gap: on wide web "Continue", "Use Google Instead" and "Use a Different Email" fill the 420 form column; the two text buttons have no border or fill but their hit area and hover tint (accentTint at 50 percent, :713-716) are the whole 420 x 44 strip, while the visible label is about 170 wide. The HANDOFF rule may not have been drawn for this canvas; I could not check it.
- Platforms: wide web; Free and Pro
- Fix idea: natural-width text buttons on wide; confirm against the beta canvas.

### Sign-in: inline text links have a 19.5 px tap target
- Severity: minor
- Evidence: lib/app/sign_in/sign_in_parts.dart:777-830 (`LinkLine`: `TextSpan` with a `TapGestureRecognizer`, `phoneFootnote` 13 with `height: 1.5`); used for "Resend Code" (email_sign_in_page.dart:889) and "support@pantas.study" (`SupportLine`)
- Gap: Button README and HANDOFF set 44 px touch targets; these links are 19.5 px high, text width only. This is the opposite of finding 3 (too small, not too big) on a phone.
- Platforms: phone web mostly; Free and Pro
- Fix idea: make the link its own text button with a 44 px hit area and no extra visible padding.

---

### Onboarding: tertiary buttons are 52 px full width on the phone (the finding 3 pattern)
- Severity: major
- Evidence: lib/features/onboarding/presentation/onboarding_study_days_step.dart:169-175 ("Every Day", `PantasButtonVariant.tertiary`), onboarding_exam_date_step.dart:186-197 ("I don't know" / "Different Date"), via OnboardingButton -> PantasButton (pantas_button.dart:~134 `height ?? PantasSize.btnPhone` = 52, `fullWidth`); mobile/project/O_Days.dc.html ("Every Day": height 52, width 100%, no border, transparent); O_Flow.dc.html ("Not Right Now": 52 full width)
- Gap: code matches the board (52 high, full width, teal text, no border). So the board itself draws the area Aedwon calls too big for a button with no border. The reviewer cannot tell code from board on this; it needs his call on the board.
- Platforms: phone; Free and Pro
- Fix idea: needs a board (borderless phone text button shorter or natural width); then change the shared tertiary phone size in one place.

### Onboarding: wide "Every Day" has 20 px side padding, the board has 16, so the label is 4 px off the title edge
- Severity: minor
- Evidence: lib/features/onboarding/presentation/onboarding_web_page.dart:275-278 (`Transform.translate(offset: Offset(-16, 0))` around a `WebButton`, `tall: true` 48 high); pantas_button_spec.dart (standard size `padLeft: s20, padRight: s20`) plus 8 px vertical padding in web_components.dart:186-191; web/project/OB_Days.dc.html (`.gh`: height 48, padding 0 16px, margin-left -16px)
- Gap: board puts the label exactly on the title's left edge (-16 margin, 16 padding). Code pads 20, so the label sits 4 px to the right and the hit area is 8 px wider than the board's (width = label + 40 vs label + 32). OB_Reminders and OB_Install `.gh` buttons use 16 and 20 padding respectively, so the shared "tall tertiary" has one padding for three boards.
- Platforms: wide web; Free and Pro
- Fix idea: a 16 px padding variant for the onboarding tertiary (0 16px), keep -16 offset.

### Onboarding: wide Back link is 40 high with 0 left padding, the board is 36 with 4
- Severity: minor
- Evidence: lib/core/ui/web/web_components.dart:1949-2010 (`minimumSize: Size(0, PantasSize.back)` = 40; `left: widget.nudge ? webBackLinkPadLeft : 0`; onboarding passes `nudge: false` at onboarding_web_page.dart:171-175); web/project/OB_*.dc.html (`.bk`: height 36, padding 0 10px 0 4px); design/system/components/BackLink/README.md (minimum height 40)
- Gap: the board and the design system disagree (36 vs 40). Code follows the design system. Padding right 10 matches; left is 0 against 4. Hit area is 4 px taller than the board and the highlight starts at the chevron instead of 4 px before it.
- Platforms: wide web; Free and Pro
- Fix idea: record that DS (40) wins over the board (36), or set 36 on the onboarding back link.

### Onboarding: guardian step reports a failed link as "Could not save your progress."
- Severity: minor
- Evidence: lib/features/onboarding/presentation/onboarding_guardian_step.dart:112-119 (`saveFailureLine(_send, message: ... : 'Could not save your progress.')`), button "Send Link" (:119)
- Gap: the action that failed is sending an email link, but the line says progress was not saved. No board or spec asks for it (none found; the Under 13 boards canvas PqxcZvKQheCogaXH6LidPM is not in the export).
- Platforms: both; Free and Pro (minors 13 to 17)
- Fix idea: "Could not send the link." with Try Again (copy is the lead's under rule 4).

### Onboarding: the save-failure line has no board
- Severity: minor
- Evidence: lib/core/error/state_patterns.dart:35-60 (`saveFailureLine`: `subhead` text plus a borderless `PantasButton` "Try Again", height 44, `fullWidth: false`, side padding 20 at standard size); docs/superpowers/plans/new-design/evidence/W4h.md line 23 ("The relevant boards have no save-failure copy"); docs/superpowers/plans/new-design/L3-W4h-app-wide-states.md:9 ("lead default")
- Gap: the line sits above the primary button on age, date, days, name, picker, guardian and consent steps with no board for its layout or size. The retry is a borderless button 44 high and 40 wider than its label, in the middle of a text row. Process rule 3 says layouts come from Claude Design boards.
- Platforms: both; Free and Pro
- Fix idea: needs a board for the save-failure line.

### Onboarding: picker error and retry copy differ between phone and wide
- Severity: minor
- Evidence: lib/features/onboarding/presentation/exam_picker_screen.dart:766-772 (wide: "Could not load exams." and "Retry" as a secondary WebButton); :1141-1145 (phone: `errorFor('exams')` -> "Could not load your exams." and "Try Again", state_patterns.dart:27); web/project/OB_PickerError.dc.html ("Could not load exams." and "Retry")
- Gap: wide matches the board. Phone has no board and uses the generic state ("your", "Try Again"). Wide empty state shows "No exams available right now." with `t.h3` (exam_picker_screen.dart:791), phone uses StateView (`phoneTitle3`), a different look for the same state.
- Platforms: both; Free and Pro
- Fix idea: one wording for both; needs a mobile board for the picker error.

### Onboarding: web picker shows every non-CSE exam as "Coming soon" with no explanation for the student
- Severity: minor
- Evidence: lib/features/onboarding/presentation/exam_picker_screen.dart:150-160 (`cseOnly = kIsWeb`, `selectable` allows only `exam_cse_pro` and `exam_cse_sub`), :666 and :713 (`'Coming soon'` tag); decision log line 814 ("CSE-only selection ... applies to onboarding")
- Gap: not a defect against the decision. The board marks only PSHS, NAPOLCOM, AFPSAT and the academies as "Coming soon"; the web build marks UPCAT, ACET, DLSU-CET, USTET, PUPCET, DOST and SM the same way. One line of grey tag text is all a student sees. Listed so the lead confirms the wording is approved ("Coming soon" for exams that are only held back for the CSE release).
- Platforms: both web; Free and Pro
- Fix idea: confirm with Aedwon; no code change needed if approved.

---

### Shell: wide sidebar is 2 px low at the top and 4 px short between search and Home
- Severity: minor
- Evidence: lib/features/shell/presentation/web_shell.dart:367-374 (padding `fromLTRB(14, 20, 14, 20)`), :397 (`SizedBox(height: PantasSpace.s14)` straight into the nav stack); web/shared/pantas.css:8 (`.side` padding 22px 14px 20px, `gap: 4px`), :10 (`.srch` margin 0 0 14px), board X_Side.dc.html
- Gap: board top padding is 22, code 20. Board search-to-Home distance is 14 margin + 4 flex gap = 18, code 14. Brand letter spacing: board -0.02em (-0.44 px at 22), code -0.264 (webH3Lg, pantas_type.dart:57).
- Platforms: wide web; Free and Pro
- Fix idea: padding top 22, spacer 18, brand letter spacing -0.44.

### Shell: sidebar account block is blank until settings load
- Severity: minor
- Evidence: lib/app/web_route_shell.dart:96 (`ref.watch(userSettingsProvider).valueOrNull?.name ?? ''`), web_shell.dart `_SidebarAvatar` (empty name draws the plain person icon, the name Text is empty)
- Gap: board X_Side always shows an initial in the avatar and the name above "UPCAT · Free". On first paint the avatar is the grey person icon and the name line is empty, then fills in. The plan half is deliberately empty while coverage is unknown (correct, not a guess).
- Platforms: wide web; Free and Pro
- Fix idea: hold the account block hidden (fade in) until the name has loaded.

### Shell: phone tab bar matches the board
- Severity: minor (no gap; recorded so the pass is visible)
- Evidence: lib/features/shell/presentation/app_shell.dart:61-96, 110-165 (inset 16, bottom 24, 64 high pill: 6 + 52 + 6; labels 12 max); mobile/project/HP_Free.dc.html (left 16, right 16, bottom 24, height 64, padding 0 6px, gap 2px)
- Gap: none found.
- Platforms: phone; Free and Pro
- Fix idea: none.

### Dialogs: confirm dialogs opened with showPantasDialog skip the design system dialog motion
- Severity: major
- Evidence: lib/core/ui/components/centered_dialog.dart:270-283 (`showPantasDialog` calls the framework `showDialog` "and changes nothing about it"); callers lib/app/routes/settings_routes_native.dart:506, lib/features/settings/presentation/pages/account_page.dart:535, whats_included_page.dart:246; the quiz, mock and report dialogs instead use `WebOverlayMotion.dialog` (lib/core/ui/web/web_components.dart:2326, lib/core/ui/components/report_form.dart:33, features/mock_exam/.../web_mock_dialog.dart); design/system/motion.md:91 ("Dialog: open dur-medium-3 420, close 320, motion-house, rise 24 and fade")
- Gap: the same CenteredDialog arrives with the 420 ms rise and fade from a quiz screen but with the framework default (a short fade, no rise) from Settings (sign out, account, what's included) on phone and wide web. Process rule 1 (phone motion is the reference) and rule 2 (do not remove approved motion).
- Platforms: both; Free and Pro
- Fix idea: make `showPantasDialog` open through `showWebOverlay` with `WebOverlayMotion.dialog` (phone form: the phone dialog recipe in motion.md).

### Dialogs: wide dialog "Cancel" is 44 high with 20 px side padding, the board is 40 to 42 with 14
- Severity: major
- Evidence: lib/core/ui/components/centered_dialog.dart:150-156 (`WebButton(variant: WebButtonVariant.tertiary)`, standard size: pantas_button_spec.dart `standard` height 44, padLeft/padRight 20, plus 8 vertical in web_components.dart:186-191); design/system/components/Dialog/README.md:23 ("Cancel (tertiary btn--sm)" = 42, padding 18); web/shared/pantas.css:73 (`.btn3` height 42, padding 0 14px); web/project/QN_ReportLimit.dc.html and HM_NoDateModal.dc.html (Cancel `btn3`, height 40)
- Gap: the borderless Cancel is 2 to 4 px taller and 6 to 12 px wider on each side of its text than the board and the DS Dialog README. It also sits 8 px from the primary button, so the two hit areas almost touch. Same shared WebButton tertiary is used for "Not Now" (install_card.dart:56-59) and notice secondary (notice_strip.dart:213).
- Platforms: wide web; Free and Pro
- Fix idea: give wide dialogs `size: PantasButtonSize.sm` for Cancel (42, 18) or a board value of 40/14, one change in CenteredDialog.

### Sheets: Cancel and Close on a phone sheet are 52 high, full width, no border
- Severity: major
- Evidence: lib/core/ui/components/pantas_sheet.dart:404-432 (`_CloseAction`: `PantasButton` tertiary, default height 52, `fullWidth`; padding 20 / 8 / 20 / max(34, inset + 20)); mobile/project/L_ChangeExam2.dc.html (Cancel: height 52, width 100%, transparent, teal); design/system/components/Sheet/README.md:24 (`btn--phone btn--tertiary`)
- Gap: code matches the board and the DS, so this is the origin of Aedwon's finding 3 (the Subjects sheet Cancel, the New questions sheet Close): a 52 x full-width strip with no border plus 34 px under it. No approved board draws a smaller one. Wide web draws a natural-width 44 high, 20 padding button (pantas_button.dart:~211 converts phone to standard).
- Platforms: phone (and wide at 44); Free and Pro
- Fix idea: needs a board for a shorter or natural-width sheet Close or Cancel; then change `_CloseAction` once.

### States: full-screen error says "Nothing you've done is lost." for every failure
- Severity: minor
- Evidence: lib/core/ui/components/state_view.dart:103, 133 (fixed `lead`/`line`); mobile and web SY_Error.dc.html (the line is on the board); decision log line 3192 (a tester did lose a quiz answer: "Could not save your progress")
- Gap: the copy matches the board, but it is shown for every route error (deferred_route.dart, bootstrap, account_page, mock setup) without checking that nothing was lost. The line is a claim no code verifies.
- Platforms: both; Free and Pro
- Fix idea: lead decides whether the claim stays; no figure involved.

### States: update-required page on wide web omits the board's second line
- Severity: minor
- Evidence: lib/features/shell/presentation/update_required_page.dart:57-62 (`WebFullNotice(title: 'Pantas needs an update to keep working.', actionLabel: 'Update')`, no `lead`); web/project/SY_Update.dc.html (second line "It takes a few seconds. Your progress is safe."); mobile SY_Update (one line only)
- Gap: the wide board has a lead line that the build drops. "A few seconds" is also not a measured figure (P10), so the omission may be right; the board needs the line removed or measured.
- Platforms: wide web; Free and Pro
- Fix idea: update the board (remove or measure the claim) rather than add the line.

### States: install card on Home is not the OB_Install board and its copy differs
- Severity: minor
- Evidence: lib/core/ui/components/install_card.dart:44-49 (title "Keep Pantas one click away", body "Install it and Pantas opens in its own window, like any app. Your progress stays the same."; iPhone/iPad "Pantas opens faster and keeps working without internet."), lib/features/home/presentation/widgets/home_install_slot.dart:20-29; web/project/OB_Install.dc.html ("Install it on this computer and it opens in its own window, like any app. Your progress stays the same either way.", full screen, 300 x 190 window illustration, 36/700 title, Not Now and Install Pantas 48 high with Enter hint)
- Gap: the board is a full-screen onboarding step; the build is a card in Home. No decision approving the card or its wording found (searched decisions and ui-audit for "install card", "one click away"). "Pantas opens faster" is an unmeasured claim. Home is another reviewer's surface; listed here because the board is OB_*.
- Platforms: wide web and phone web; Free and Pro
- Fix idea: confirm with Aedwon; if kept, needs a board for the card and measured or removed "opens faster".

### States: no offline banner by design
- Severity: minor (no gap)
- Evidence: docs/superpowers/specs/2026-08-03-offline-and-network-posture-design.md:98-100 ("No connectivity banner ... No offline indicator"); lib/core/network is empty
- Gap: none. The spec forbids it. Recorded so no one reports it as missing.
- Platforms: both; Free and Pro
- Fix idea: none.

---

## Button inventory (finding 3)

Heights and paddings are from code (Flutter logical px). "Hit area" is the tappable box. Board value is read from the board source. "Over" marks a borderless button that takes more room than its board draws or than the design system sets.

| Widget | File:line | Height | Padding (L/R, V) | Hit area | Board value | Over? |
|---|---|---|---|---|---|---|
| Phone sheet Cancel / Close (`_CloseAction` -> PantasButton tertiary) | pantas_sheet.dart:404-432 | 52 | 20 sides on the row; button 20/20 (phone) | full width x 52 | L_ChangeExam2 Cancel 52, width 100% | Matches board; board is what Aedwon calls too big (needs a board) |
| Wide sheet Cancel / Close (PantasButton tertiary -> WebButton) | pantas_button.dart:~211, pantas_sheet.dart:423 | 44 | 20/20, 8 V | label + 40 x 44 | btn3 40 to 42, 14 | Yes, +2 to +4 high, +12 wide |
| Wide dialog Cancel (WebButton tertiary) | centered_dialog.dart:150-156 | 44 | 20/20, 8 V | label + 40 x 44 | btn3 42/14 (QN_ReportLimit 40); DS Dialog 42/18 | Yes |
| Phone dialog buttons | centered_dialog.dart:~226-250 | 46 pill, 12 sides | 12/12 | half the row | MK dialogs pill, filled neutral (not borderless) | No (filled) |
| "Every Day" phone (OnboardingButton tertiary -> PantasButton) | onboarding_study_days_step.dart:169-175 | 52 | 20/20 | full width x 52 | O_Days 52, width 100% | Matches board (finding 3 pattern) |
| "I don't know" phone | onboarding_exam_date_step.dart:186-197 | 52 | 20/20 | full width x 52 | O_DateKnown / O_Days pattern 52 | Matches board |
| "Every Day" wide (WebButton tall tertiary, translate -16) | onboarding_web_page.dart:275-278, 236-250 | 48 | 20/20, 8 V | label + 40 x 48 | OB_Days `.gh` 48, 0 16, margin-left -16 | Yes, +8 wide, label 4 px off edge |
| "Not Now" (install card, WebButton tertiary) | install_card.dart:56-59 | 44 | 20/20 | label + 40 x 44 | OB_Install `.gh` 48, 0 20 | Smaller than board (44 vs 48), padding equal |
| Notice secondary (WebButton tertiary) | notice_strip.dart:213-216 | 44 | 20/20 | label + 40 x 44 | btn3 42/14 | Yes (+2 high, +12 wide) |
| Phone Back (OnboardingBackBar TextButton) | onboarding_frame.dart:512-530 | 44 min | L4 / R8, 0 V | 44 x label+icon+12 | O_* Back 44, 0 8 0 4 | No |
| Wide Back (WebBackLink) | web_components.dart:1949-2010 | 40 min | L0 (onboarding) or 8, R10 | label+chevron+10 x 40 | OB `.bk` 36, 0 10 0 4 | +4 high (DS says 40), L 0 vs 4 |
| Sign-in "Use Google Instead", "Use a Different Email" (SignInTextButton) | sign_in_parts.dart:685-760 | 44 | 0 | full form width (420 wide) x 44 | no board in export | Probably; wide text link fills the column |
| Waiting "Read the tester guide" (GuideLink) | beta_waiting_page.dart:337-367 | 44 min | none, row hit box | label + arrow x 44 | beta canvas (not exported); decision line 2651 "link A" | Unknown |
| Inline "Resend Code", support email (LinkLine) | sign_in_parts.dart:777-830 | 19.5 | 0 | text only | no board | Too small, not too big |
| Toast "Undo" (_ToastAction) | toast.dart:137-185 | 44 | 10/10, 6 V | label + 20 x 44 | DS Toast README 44 | No |
| Save-failure "Try Again" (PantasButton tertiary) | state_patterns.dart:44-58 | 44 | 20/20 | label + 40 x 44 | no board | Yes, no board |
| Notice row toggle (TextButton) | notice_strip.dart:104-115 | 52 min (`_headMin` = 44 + 8) | L18, 8 V | full notice row x 52 | no board checked | Whole row is the target; not a lone text button |
| Sidebar search / items (TextButton) | web_shell.dart:511, 648-657 | 38 / 40 | 12/10, 12/12 | full sidebar width | X_Side 38 / 40, pad 0 12 | No |
| Tab bar item | app_shell.dart:~296-345 | 52 | none | item width x 52 | HP_Free 64 bar, 6 inset | No |

## Figures (P10)

Every number a student sees on these surfaces, with its source.

| Figure | Where | Source |
|---|---|---|
| "6-digit code" | email_sign_in_page.dart:703 | Design/server rule (code length). Named in the server contract; not a measurement. |
| "You can request a code in M:SS", "Didn't get it? You can resend in M:SS" | email_sign_in_page.dart:788, 874 | Measured: seconds returned by the server (`resendAfterSeconds`). |
| Countdown tiles days, hours, min | beta_waiting_page.dart:49-79, 481-487 | Computed from the server `waitUntil` (named algorithm: whole minutes, rounded up). |
| "The beta starts Nov 9" | beta_waiting_page.dart:257 | Published date, but hard-coded (not from the data). |
| Age stepper: starts at 17, range 5 to 100, "Enter an age from 5 to 100." | onboarding_age_gate_step.dart:550 | Aedwon decision Nov 10 ("A"; decision log line 2953). Design values, approved. |
| Under 13 blocked, "You are still under 18." | onboarding_age_gate_step.dart:273, 279 | Legal thresholds (AgePolicy), published policy. |
| "Step N of 6" (screen reader only) | onboarding_frame.dart:560 | Count of the six segments, not a measurement. |
| "28 days from today", "N days from today", "today" | onboarding_exam_date_step.dart:~300-330 | Computed from the exam date and today (calendar arithmetic). |
| Exam date "Wednesday, November 11, 2026" | onboarding_exam_date_step.dart:262-270 | Published: earliest future `publishedSittings` of the catalog. Label says "this year's" even if the sitting is next year. |
| "N study days a week", "Your exam is in N days" | onboarding_study_days_step.dart:~280-320 | Count of the student's own tiles; calendar arithmetic. |
| Sidebar "Free" / "Pro" and exam name | web_route_shell.dart:97-104 | Real entitlement and active exam; blank while unknown. |
| "Ctrl K" / key hints | web_shell.dart `_keyHintWidth` | Shortcut label, not a figure. |
| "Daily content limit reached. Try again tomorrow." | content_limit.dart:5 | Named server policy; no number shown. |
| "It takes a few seconds" | SY_Update board only (not in code) | Invented claim on the board; unmeasured. |
| "Pantas opens faster and keeps working without internet" | install_card.dart:47 | Unmeasured claim (not a number). |
| "Nothing you've done is lost." | state_view.dart:103 | Unverified claim; no code checks it. |



---

# SLICE B: Home, Plan, Performance, Record
# UI inspection B: Home, Progress/Performance, Record/Tendencies, dialogs (CSE, Free and Pro, phone and wide web)

Policy commit: origin/main 78a7d90a6 (fetched). Code root: worktree on qa/cse-release-r1 (67ed1b52b). Read only. Boards: pantas-handoff web/project and mobile/project. Boards were converted to text and read; button and spacing values were read from the board HTML. Pixel spacing was NOT measured on every element: only the spacings the code comments cite, and every button, were compared. Exam names on CSE are "CSE Professional" and "CSE Subprofessional" (content/exams/catalog.json), long names the boards never show (see finding "Home: long CSE names").

Where a board ("HM_" web, "HP_/HE_/DP_/DT_/YO_" phone) and HANDOFF.md disagree, this file follows the board and says so.

### Home (phone): extra "Close" button under the Lessons, Reviews and New questions sheets
- Severity: major
- Evidence: lib/features/home/presentation/home_today_screen.dart:686-701 (`closeLabel: 'Close'`); lib/core/ui/components/pantas_sheet.dart:365-368 and 402-428 (`_CloseAction`: padding 20/8/20/max(34, inset+20), `PantasButton` tertiary, height null so 52 `btnPhone`, `fullWidth` default true); board mobile/project/HE_ManyLessons.dc.html (Lessons, Reviews and New questions sheets: grabber, title row, rows, ONE 52 px primary button, padding 8/20/34, no Close or Cancel anywhere); web board HM_ReviewsPanel/HM_NewQPanel/HM_LessonsPanel (drawer has an X in the header only)
- Gap: board shows no text button under the sheet. Code adds a full-width 52 px tap box, plus 8 px above and 34 to 54 px below (94 to 114 px of extra sheet height on a device with a 34 px home bar), under the Start button. This is Aedwon's finding 3 ("New questions sheet Close") on this surface. Dismiss already works by scrim tap and drag (pantas_sheet.dart:340-348).
- Platforms: phone; Free and Pro
- Fix idea: drop `closeLabel` on these three sheets so the sheet ends at the Start button with the board's 34 px bottom padding (the 32 px bottom padding in `TodayQuestionsSheet`, lib/core/ui/components/today_questions.dart, becomes 34)

### Home (phone): extra "Cancel" button under the exam date sheet
- Severity: major
- Evidence: lib/features/home/presentation/home_tab.dart:183-199 (`closeLabel: 'Cancel'`); pantas_sheet.dart:402-428; board mobile/project/HP_NoDate.dc.html (date sheet: title, subtitle, month grid, "Know the exact day?" strip, "Save" only); HP_MonthOnly
- Gap: board has Save as the last element. Code adds a full-width 52 px "Cancel" tertiary row with 8 px above and 34+ below. Wide web has a Cancel (see next finding) because HM_NoDateModal draws one; the phone board does not.
- Platforms: phone; Free and Pro
- Fix idea: remove `closeLabel` from this sheet

### Home (wide web): exam date dialog "Cancel" is larger than the board's
- Severity: minor
- Evidence: lib/features/home/presentation/widgets/home_exam_date_sheet.dart:~146-152 (`WebButton tertiary`, default size standard: height 44, padding 20/20 per lib/core/ui/components/pantas_button_spec.dart:101-109); board web/project/HM_NoDateModal.dc.html `<button class="btn3">Cancel</button>` and web/shared/pantas.css:73 (`.btn3`: height 42, padding 0 14, radius 11, 16/600)
- Gap: board 42 high, 14 px sides. Code 44 high, 20 px sides (+2 px tall, +12 px wide). The "Save" beside it is correct (44, `.btn`).
- Platforms: wide web; Free and Pro
- Fix idea: size the tertiary dialog button 42/14 (design system `btn--dialog` or a `height: 42, sidePadding: 14`)

### Home (wide web): notice buttons "Later", "Got It", "Not Yet", "Learn More" are larger than the board's
- Severity: minor
- Evidence: lib/features/home/presentation/widgets/home_web_layout.dart:466-475 (`WebButton` tertiary standard, `sidePadding: 16`, height 44) and lib/core/ui/components/notice_strip.dart:208-216 (wide branch, no sidePadding: 44 high, 20 sides); board web/project/HM_NoDate.dc.html `<button class="btn3">Later</button>` (42 high, 14 sides)
- Gap: 44 high with 16 (notice) or 20 (strip) side padding versus board 42 with 14. Two code paths also disagree with each other (16 vs 20). Primary "Add Exam Date" is 156 px per comment and matches.
- Platforms: wide web; Free and Pro
- Fix idea: one size for the tertiary notice button, 42 high, 14 sides

### Performance (phone): extra "Cancel" button under the Subjects filter sheet
- Severity: major
- Evidence: lib/features/home/presentation/performance_page.dart:397-434 (`closeLabel: 'Cancel'`); pantas_sheet.dart:402-428; board mobile/project/DT_FilterFlow.dc.html (sheet text: "Subjects", "All subjects", "Mathematics", "Science", "Reading Comprehension", "Language Proficiency", no Cancel)
- Gap: board sheet is title plus a list. Code appends a full-width 52 px tap box with 8 px above and 34+ below. This is Aedwon's finding 3 ("Subjects sheet Cancel").
- Platforms: phone; Pro (the picker opens only for Pro, performance_page.dart:250)
- Fix idea: remove `closeLabel`; keep the 20 px padding of the body

### Home: lesson rows carry "Part X of Y · N questions" and the topic line where the Home boards show subject and "10 min"
- Severity: major
- Evidence: lib/features/home/presentation/widgets/home_today_checklist.dart:324-330 (wide) and 587-593 (phone, `topicLine: 'Up next · $subject'`); home_today_screen.dart:919 and 933 (Lessons panel rows); lib/core/ui/components/lesson_label.dart:9-18 (`biteLabelText`: "Part 2 of 9 · 3 questions", "5 questions"); boards web HM_Free/HM_Everything/HM_LessonsPanel ("Stoichiometry / Chemistry / 10 min"), mobile HP_Free/HP_Pro/HE_ManyLessons; commit 4f4b01135 ("Show each lesson's part and real question count instead of typed-in minutes"); spec docs/superpowers/specs/2026-11-13-bite-sized-lessons-design.md:87 and 443 ("Lesson label ... on every surface that shows minutes; minutes left replaced or removed"; 108 "You see a mockup before anything is built"); decision docs/superpowers/decisions/2026-10-19-pwa-launch-log.md:3250 and 3490
- Gap: the approved Home boards still draw the minutes. The code draws the label on every Home lesson row and every row of the Lessons panel, a line the Home boards do not have. Approval: the label option was ruled by Fable 5.2, not by Aedwon. His words in the log, verbatim: "for things needing my decision, consult a fable 5.2 agent instead" (pwa-launch-log.md:3250, 3490). A direct Aedwon approval of the Home rows with the label: not found. Home boards were not redrawn with the label (HM_* and HP_* still show "10 min"). Same extra-text pattern as finding 2.
- Platforms: both; Free and Pro
- Fix idea: needs a board (Home boards must be redrawn with the label, or the Home rows return to subject only)

### Home: footer time captions ("About 35 min left today", "About 12 min", "10 min") dropped, no ruling recorded for the empty space
- Severity: minor
- Evidence: home_today_checklist.dart:566-570 (`_footerCaption` returns only "The mock comes first today"; comment: "no measured or published figure gives today's minutes yet ... Aedwon decides"); home_exam_day.dart:74 ("Its time estimate is left out"); boards web HM_Free, HM_NoDate ("About 12 min"), HM_ExamDay ("About 6 min"), HM_DayStart ("About 45 min today"), mobile HP_*; spec line 443
- Gap: the boards show a figure. The spec replaces it. The code shows nothing in the footer band (left of the button). Dropping an unmeasured minutes figure is correct under "Never invent a figure". The footer band (surface-inset, 20/16/20/18 padding) now holds only a right-aligned button on most days. No decision records that the empty band is approved.
- Platforms: wide web mainly (phone has no footer caption); Free and Pro
- Fix idea: needs a board for the band without the caption (or restore a measured figure, such as questions left)

### Home: "easy reviews" warm-up on exam day
- Severity: minor
- Evidence: lib/features/home/presentation/widgets/home_exam_day.dart:218-221 ("Nothing new today. If you want a warm-up, $reviewsTotal easy reviews are here."); lib/features/roadmap/domain/build_roadmap.dart:130-135 (`selection.reviewQuestionIds.take(10)`; comment "keeps the scheduler's actual order"); board web/project/HM_ExamDay.dc.html and mobile HP_ExamDay ("10 easy reviews")
- Gap: the board says "easy". The code takes the first 10 reviews the scheduler returns. No difficulty field exists (HANDOFF "no difficulty field") and nothing picks easy questions. The word is a claim the app cannot back (P10). The cap of 10 is a design choice with no measured or published source.
- Platforms: both; Free and Pro
- Fix idea: change the copy to "10 reviews" and ask for a ruling; copy sits in an approved layout so the lead settles it under rule 4

### Home: Pro welcome notice is not "once"
- Severity: minor
- Evidence: lib/features/home/application/home_notices.dart:296-307 (`if (pro)` adds the welcome notice with `dismissalToken: 'yes'`); home_notice_strip.dart:147-150 (primary "See What's New" dismisses and opens /performance); dismissal stored per device (home_notice_strip.dart:133-136); board mobile/project/HP_ProWelcome.dc.html title "Notice · Welcome to Pro (once)"
- Gap: board says once. Code shows "You're in. Welcome to Pro." to every Pro account on every device until the student presses a button, including a student who has been Pro for months and opens a new device or browser. The button "See What's New" opens Performance, not a what's-new page (board names no destination).
- Platforms: both; Pro
- Fix idea: key the token to the entitlement start date (or store dismissal on the account)

### Home: trial notice wording differs from the web board
- Severity: minor
- Evidence: home_notices.dart:74-93 (web: "Your free trial ends on X. You won't be charged.", comment "approved wording, proposal v1, 24 October 2026") and 275-295 (phone: "Google Play charges ₱x on X to keep Pro. Cancel any time before then."); web board HM_Trial ("You'll be charged ₱99 on Oct 16 to keep Pro. Cancel any time before then."); mobile HP_Trial matches the phone code
- Gap: web code deliberately differs from HM_Trial because the web trial has no charge. The board was not redrawn. No board shows the approved web text.
- Platforms: wide web; Pro (trial)
- Fix idea: needs a board for the web trial wording

### Home: beta wording on Home (note only; handled by others)
- Severity: minor
- Evidence: lib/features/home/application/home_notices.dart:131 ("You earned 1 year of Pro"), 132 ("Thank you for testing Pantas."), 166 and 180 ("$counted of 5 beta days. Ends $ends."), 167 and 181 ("A day counts when you finish your whole Today plan. Reach 5 by ..."), 176 and 186 ("Send the exit survey by ..."), 177 ("It has 7 short questions. Send it to earn 1 year of Pro."), 187; buttons 135-136 ("See Your Reward", "Later"), 169, 172 ("Take the Survey", "See Your Days"). No beta text elsewhere on Home, Progress, Record or Tendencies. No board draws any beta notice (HM_Notice* and HP_* have none).
- Gap: copy and layout with no board. The word "beta" shows in the title line of the notice.
- Platforms: both; Free and Pro (testers only)
- Fix idea: others own the wording; needs a board if the notice stays after beta

### Home: "More about you" icons on wide web differ from the board
- Severity: minor
- Evidence: lib/features/home/presentation/widgets/home_web_layout.dart:147-160 (`Icons.show_chart`, `Icons.auto_awesome_outlined`, size 24, `WebRow` default padding); board web/project/HM_Free.dc.html (`Your record`: svg "M4 19.5h16" plus "m5.5 15 4.2-4.4 3.3 3 5.5-6.1"; `Your tendencies`: two-star sparkle svg; card padding 18/18/18/20; 17 px title)
- Gap: Material glyphs replace the board's two drawn icons. Phone uses the right drawn SVGs (home_tab.dart:343-358), so wide web differs from phone. Title style is `webLead` (check 17 px) inside `WebRow` padding, not the board's 18/18/18/20 card padding.
- Platforms: wide web; Free and Pro
- Fix idea: reuse the phone SVG paths and the board padding

### Home: long CSE names in the week strip and notices (CSE specific)
- Severity: minor
- Evidence: lib/features/home/presentation/widgets/home_masthead.dart:190-233 and 340-405 (phone strip shrinks to 5, 4 or 3 days to fit the chip, decision D196); chip text `masthead.examShortName` with no ellipsis (line 386); content/exams/catalog.json ("CSE Professional", "CSE Subprofessional"); boards use "UPCAT" (6 characters) and show 7 days
- Gap: with "CSE Subprofessional" the phone chip is wider than any board chip, so the strip shows fewer days than the boards. Behavior is an approved rule (D196) but no board shows a CSE-length name; the chip is 3 lines at large text.
- Platforms: phone; Free and Pro
- Fix idea: needs a board for a long exam name (or use "CSE-SP" style short names as HM_NoContent does)

### Home (wide web): no ruling for the Reviews and New questions drawer button being full width
- Severity: minor
- Evidence: lib/core/ui/web/web_side_overlay.dart:430-440 (`WebButton large expand: true`); board web/project/HM_ReviewsPanel.dc.html (`<a class="btn lg" style="width: 100%">Start Reviews`); HANDOFF.md "No full-width buttons on wide screens"
- Gap: code matches the board; the board breaks the HANDOFF hard rule. Report only so that the two documents are reconciled.
- Platforms: wide web; Free and Pro
- Fix idea: lead rules which wins

### Home: Free versus Pro
- Severity: minor
- Evidence: home_performance_card.dart:130-134, 190-210 (Free: "Pro" pill beside "See all topics and lessons", wide "PRO" tag at 231-247); boards HP_Free vs HP_Pro, HM_Free vs HM_ProWelcome
- Gap: no mismatch found. Free and Pro Home are identical except the pill, as the boards. The "Free placeholder card" the brief mentions does not exist on Home in the boards or the code. "More about you" shows for Free (Tendencies opens with locked cards, see Tendencies finding). Recorded for completeness.
- Platforms: both; both
- Fix idea: none

### Home: first-time loading and error states
- Severity: minor
- Evidence: home_tab.dart:57-61 and 140-144, home_today_screen.dart:651-662, lib/core/error/state_patterns.dart:27 ("Could not load your plan." / "Could not load your performance." / "Could not load your home."), lib/core/ui/components/state_view.dart:142-150 (phone "Try Again": `PantasButton` secondary, height 44, `fullWidth: true` up to `_textMax`, rounded rectangle); boards web L_PlanSlow (shapes only), mobile L_PlanSlow, PL_Error, DT_Error ("Try Again": 44 high, 22 px sides, natural width pill, radius 99, tint fill)
- Gap: loading shapes match L_PlanSlow. Phone "Try Again" is a full-width rounded rectangle up to the text measure; board DT_Error is a natural-width pill (about 100 px wide). The offline state of Home has no board: an offline student sees the same "Could not load your plan." Home shows no stale or cached copy.
- Platforms: phone (button), both (offline); Free and Pro
- Fix idea: "Try Again" natural width pill per DT_Error; offline needs a board

### Plan: History entries for six causes show the generic "Your plan changed on Oct 8."
- Severity: major
- Evidence: lib/features/home/application/plan_data.dart:38-62 (`planHistoryText` handles examChanged, examPassed, missingExamDate, assessmentCompleted, mockAnswersRecorded, backlogCapped, advanced; `_ =>` "Your plan changed on <date>." for missedWork, examDateChanged, scopeChanged, contentChanged, orderChanged, studyDaysChanged; lib/features/roadmap/domain/roadmap.dart:109-125 enum); boards web PL_History/PL_HistoryEnd and mobile DP_History ("You were away 2 days. What you missed was spread over the days left, so new questions went from 7 to 8 a day.", "Your exam date moved to Nov 11. Your days were resized.", "You now rest on Sundays. Your study days were resized.", "Chemistry moves up after this week's results, so its lessons come first.", "New lessons were added for Reading Comprehension.", "You turned off Trigonometric identities. It left your plan.")
- Gap: the boards draw specific reasons. The code has no text for them and falls back to a bare date line for the most common changes (missed days, exam date moved, study days changed). Withholding invented numbers (7 to 8 a day, "2 days") is right under "Never invent a figure", but the plain facts the log does store (days missed, old and new date, weekdays) are not used.
- Platforms: both; Pro (History is Pro; Free sees the lock card)
- Fix idea: add one sentence per cause from stored facts; needs the stored fields checked

### Plan: "Your plan had not started on this day." has no board
- Severity: minor
- Evidence: lib/features/home/presentation/plan_screen.dart:254-257; searched boards web and mobile (grep "had not started"): none; docs/ui-audit.md and decisions: none found
- Gap: unrequested text for a day before the plan existed; plain unstyled `Text` in a card (wide, 80 px vertical padding) or at the page top (phone) with no icon, no board.
- Platforms: both; Free and Pro
- Fix idea: needs a board

### Plan (wide web): History "See more" is a link, board is a white button; and a "Loading" label
- Severity: minor
- Evidence: lib/features/home/presentation/plan_web.dart:557-565 (`WebTextLink` "See more" with arrow; label "Loading" while fetching, also 539 inside the card); board web/project/PL_History.dc.html (`<a class="btnw">See more</a>`: 44 high, 18 px sides, 1 px ring, centered, 18 px above)
- Gap: link text 15/600 with a 16 px arrow versus a bordered 44 px white button; "Loading" text appears nowhere on a board.
- Platforms: wide web; Pro
- Fix idea: `WebButton white` "See more"; no label change while loading (disable it)

### Plan (phone): History "See more" row is 52 px high
- Severity: minor
- Evidence: lib/features/home/presentation/plan_page.dart:855-866 (`PantasButton` tertiary accent, height null so 52 min, full width, 13 px chevron); board mobile/project/DP_History.dc.html (row: padding 13 16, 17/400 teal text at 1.35 line height, 14 px chevron, 0.5 px top border: about 49 px)
- Gap: about +3 px tall; label weight is the button's 600 where the board is 400 (code comment says regular weight 17). Minor size excess, within the card.
- Platforms: phone; Pro
- Fix idea: draw the row as a plain tap row at 13/16 padding

### Performance: table header row on wide web has text the board does not draw
- Severity: minor
- Evidence: lib/features/home/presentation/widgets/web_performance_layout.dart:490-497 (`PantasTableColumn`: "Subject"/"Topic"/"Lesson", "Answered", "Accuracy"); lib/core/ui/components/data_table.dart:29 (header drawn uppercase); design/system/components/DataTable/README.md:10 (header cells specified); boards web/project/PF_Subjects.dc.html and PF_Topics.dc.html (rows only: title with small sub, "9 answered" right text, bar, %, chevron; no header row)
- Gap: code draws a SUBJECT / ANSWERED / ACCURACY header row (and an empty header column for the bar) that none of the PF boards has. The system README would ask for it, the boards do not.
- Platforms: wide web; Free and Pro
- Fix idea: hide the header (or needs a board decision)

### Performance (phone): loading skeleton has no board
- Severity: minor
- Evidence: lib/features/home/presentation/performance_screen.dart:92-104 (`PerformanceSkeleton`), 41-74 (wide `WebPerformanceLoading`); boards: L_ProgressSlow is "Figures from your history" for Your tendencies (mobile/project/L_ProgressSlow.dc.html text "How you work / Under pressure ..."), not Performance
- Gap: no L_ board for Performance loading. Shapes exist in code.
- Platforms: both; Free and Pro
- Fix idea: needs a board

### Performance: overall accuracy for CSE Professional is a weighted mean
- Severity: minor
- Evidence: lib/core/metrics/overall_accuracy.dart:23-58 and 93-150 (weights General Information 5, Verbal 30, Analytical 35, Numerical 30, Clerical (weight line 140+); CSE Professional only; areas with no answers are skipped and the remaining weights are renormalized); CSE Subprofessional uses the plain ratio; Home and Performance both print "61%" from it
- Gap: this is an algorithm output (named weights). The source of the weights was not found in the files read (a CSC published blueprint is the likely source; confirm). When one area has answers and the others have none, overall equals that area alone (a single answer in Analytical gives 100% or 0% overall). No minimum answer count is applied. Spec Section 1 allows tier T3 only as designed.
- Platforms: both; Free and Pro (CSE Professional)
- Fix idea: confirm the weights are CSC-published; consider a minimum before showing a gauge

### Record: "61% this week" is not always this week
- Severity: major
- Evidence: lib/features/home/presentation/record_page.dart:~154-185 (`'${accuracySeries.last.accuracy.round()}%'` with "this week" and an axis label "This week"); lib/features/home/application/record_provider.dart:317-345 (`sortedWeeks` holds only weeks that have answers; no check that the last week is the current one); board web/project/MY_Record.dc.html ("61% this week", "Sep 2", "This week")
- Gap: a student who last answered three weeks ago sees that week's accuracy labelled "this week". It is a measured figure with a wrong label. The empty line message "Your line starts after two weeks of answers" (record_page.dart) is true only for two weeks that have data, not two calendar weeks; weeks with no answers are skipped, so the line has uneven x spacing.
- Platforms: both; Free and Pro
- Fix idea: label the last point by its real week (or "last week with answers") or drop the label when it is not the current week

### Record: "N day streak" is not decayed when days are missed
- Severity: major
- Evidence: lib/features/home/application/record_provider.dart:~196 (`dayStreak = streakRow?.current ?? 0`); lib/features/quiz/domain/streak/streak_evaluator.dart:26-85 (streak is written only when a session completes: `_next` resets to 1 if the gap is not covered); no read-time check of `lastActiveDate` against today found in lib/features/home; boards MY_Record, MY_RecordRest ("12 day streak", "since Oct 3, 2026", no "since" line over a rest day)
- Gap: the number shown is the value stored at the last completed session. A student who stopped three weeks ago still sees "12 day streak" (and "since ..." only if the history proves it) until the next session. The figure is wrong while it is stale. Home day-off copy "your streak is safe" (home_state_card.dart:60) relies on the same value.
- Platforms: both; Free and Pro
- Fix idea: evaluate the streak against today's date when reading (show 0 when more than the allowed missed study days have passed)

### Record: "questions answered" counts every mock item and "time in sessions" uses wall clock
- Severity: minor
- Evidence: record_provider.dart:~245-265 (mock attempts add `row.scoreTotal`, the number of items on the paper, including blanks; quiz attempts add `completedAt - startedAt` with no idle cap; mocks add `elapsedSeconds`); boards MY_Record ("1,284 questions answered", "35h 30m time in sessions")
- Gap: a CSE mock with 40 blanks adds all of its items to "questions answered". A quiz left open for a night and finished next morning adds hours. Both are measured values (T1) but not what the label says. The label already avoids "time studied" (provider comment).
- Platforms: both; Free and Pro
- Fix idea: count answered items only; cap or exclude idle time

### Tendencies: "Peak hour" and the archetype use ungated bucket accuracy
- Severity: minor
- Evidence: lib/features/home/application/how_you_work_provider.dart:~396-425 (`bestBucket` = hour bucket with highest accuracy; no minimum answers per hour; shown with "Average session" and "Total sessions"); lib/features/metrics/signals/time_of_day_signal.dart:15 (`minDataPoints` 7 for the whole window); lib/features/metrics/archetypes/archetype_catalog.dart:10-110 (invented cutoffs: hour >= 18 "late", average session <= 12 min "short", <= 12000 ms "fast", >= 25 min, weights 0.3/0.4/0.5/0.7/0.8); the five tendencies are gated by lib/features/metrics/domain/tendency_confidence.dart (5 successes and failures, 30 times per side, alpha 0.05); board web/project/MY_TendPro.dc.html ("9 pm Peak hour", "18 min Average session", "41 Total sessions", "Deep Thinker")
- Gap: the five tendencies pass a significance test. "Peak hour" does not: a one-question session at 9 pm that was right makes 9 pm the peak. Archetype labels ("Night Owl", "Deep Thinker", "Time Master") come from cutoffs the app invented; progress spec Section 1 puts "what a behavior means" in tier T4. Names and cutoffs are on the approved boards as labels, not as figures.
- Platforms: both; Pro (Free sees locked cards)
- Fix idea: apply a minimum per bucket before naming a peak hour; ask for a ruling on the archetype cutoffs

### Tendencies (phone and wide web): Free page matches except one label
- Severity: minor
- Evidence: lib/features/home/presentation/tendencies_page.dart:90-115 (section label "YOUR TENDENCIES" over locked cards, text "Unlock complete insights into your study habits, pacing, and working hours.", `PantasButton` "Unlock with Pro" 52 px full width); boards web/project/MY_TendFree.dc.html (header "What we found", same copy), mobile YO_Free
- Gap: wide board calls the group "What we found"; phone code says "YOUR TENDENCIES" (taken from YO_Free). Not a defect if YO_Free is the phone board.
- Platforms: phone; Free
- Fix idea: none unless YO_Free differs (not compared line by line)

### Wrapped entry points (HANDOFF: deferred)
- Severity: minor
- Evidence: lib/features/home/presentation/record_screen.dart:18 (`wrappedRecordRowProvider` returns null; the "Your Wrapped" row on MY_Record is not drawn); lib/app/routes/wrapped_routes.dart:7-12 (route `/wrapped/:artifactId` exists); lib/app/router.dart:79-81 (wide web redirects it to /record); lib/app/start_location.dart:127-128 ("Nothing links to the reveal" returns /home on a cold start); grep of lib/ for pushes to /wrapped: none; share and shared-links pages exist in lib/features/wrapped/presentation but nothing outside that folder imports them
- Gap: a student cannot reach Wrapped from any button. On the phone build a typed or deep link to `/wrapped/<id>` would open the reveal page. Boards WR_* (Wrapped and share) are not built as UI entry points. This is the deferred state, as HANDOFF asks.
- Platforms: phone only (deep link); both
- Fix idea: none needed; optionally redirect the route on phone as on wide web

## Button inventory (finding 3)

Hit area: a `TextButton` with a minimum size equals its minimum size (full width when `fullWidth`). "Board" is the value in the board HTML or CSS. "none" means the board draws no such button.

| Widget | File:line | Height | Padding | Hit area | Board value |
|---|---|---|---|---|---|
| `PantasSheet` "Close" (Lessons, Reviews, New questions sheets) | home_today_screen.dart:697 via pantas_sheet.dart:365,402-428 | 52 (`btnPhone`) | container 20 sides, 8 top, max(34, inset+20) bottom; button 8 vertical | full width x 52, 94 to 114 px of sheet | none (HE_ManyLessons) |
| `PantasSheet` "Cancel" (exam date) | home_tab.dart:188 via pantas_sheet.dart | 52 | same | full width x 52 | none (HP_NoDate) |
| `PantasSheet` "Cancel" (Subjects filter) | performance_page.dart:400 via pantas_sheet.dart | 52 | same | full width x 52 | none (DT_FilterFlow) |
| `WebButton` tertiary "Cancel" (exam date dialog, wide) | home_exam_date_sheet.dart:~146 | 44 | 20 left, 20 right, 8 top/bottom | 44 x (label+40) | `.btn3` 42 high, 14 sides (HM_NoDateModal) |
| `WebButton` tertiary notice buttons (Later, Got It, Not Yet, Learn More) wide | home_web_layout.dart:468-475 | 44 | 16 sides (explicit) | 44 x (label+32) | `.btn3` 42, 14 sides |
| `WebButton` tertiary in `NoticeStrip` wide branch | notice_strip.dart:208-216 | 44 | 20 sides | 44 x (label+40) | `.btn3` 42, 14 sides |
| `PantasButton` tertiary notice "Later"/"Got It" phone | notice_strip.dart:238-246 | 44 | half of a pair, 8 gap | half width x 44 | 44, half width, radius 12, teal 15/600 (HP_NoDate): matches |
| `PantasButton` tertiary accent "See more" (History, phone) | plan_page.dart:855-866 | 52 min | 8 vertical, full width | full width x 52 | about 49 (DP_History row 13/16 padding) |
| `WebTextLink` "See more" (History, wide) | plan_web.dart:561-565 | text line (about 20) | 0, arrow | text only | `.btnw` 44, 18 sides, bordered (PL_History): size smaller, style differs |
| `WebTextLink` "View full plan" (Home, wide) | home_today_checklist.dart:401-405, 646-650 | 20 (SizedBox) | 0 | text only | link in a 19 px label row |
| `WebTextLink` "View full plan" (Home, phone) | home_today_checklist.dart:671-675 | text line | 0 | text only | link on the Today label row |
| `WebTextLink` "Add your name" (Tendencies card) | tendencies_page.dart:~240 | text line | 0 | text only | text link in the card (MY_TendNew) |
| `WebTextLink` / `WebTextAction` "Change" (Plan week) | plan_day_page.dart:447 and 526 | text link / `btnSm` 42 (WebTextAction default height `btnSm`) | 0 / 18 sides per spec | text / 42 x label+36 | `.btn3.teal` 42 high, 14 sides (PL_Week) |
| `PantasButton` "Try Again" (phone error) | state_view.dart:142-150, 277 | 44 | 24 sides, full width to the text measure | up to 280 x 44 | natural width pill 44, 22 sides (DT_Error) |
| `PantasIconButton` "Close" (Plan drawer, wide) | plan_web.dart:616 | 32 per comment | n/a | 32 | 32 px button rising 8 px (board `.ebr`) |
| `PantasIconButton` "Dismiss" (notice, wide) | home_web_layout.dart:394-398 | icon button default | 6 right | 44 | 44 `.ib` |

No other borderless text buttons were found in lib/features/home, lib/features/roadmap, lib/features/metrics. Quiz, Study, lesson, Settings and paywall use the same shared sheet and are for other reviewers.

## Figures (P10)

Source codes: M = measured from the student's own use; P = published by the testing body or the app's own content; A = output of a named algorithm; U = user-entered; F = unsourced or inferred (flagged).

Home
- Week strip day numbers and states (Done, Partly done, No study, Planned): M (own sessions) and the plan. Today dot fraction: M.
- Exam chip: day, month, "N days", "in Nov", "Today", "Passed": U (the student's own exam date).
- Greeting hour band "umaga/hapon/gabi" (before 12, before 18, else): device clock, no figure.
- "N lessons · N questions" in "Today's done": plan content count (P, app content) and the quiz count (A, the number the lesson's quiz will serve).
- "Part X of Y · N questions": part numbers are app content (P); N is the quiz size the app will serve (A: lessonQuizCountProvider). See the label finding.
- "N today", "N of M read" (Lessons row): plan (A, roadmap) and M (own reads).
- "N due · M sessions of K" (Reviews): N from the review scheduler (A, FSRS due list); K is the student's own session length setting (U); M derived.
- "N of M" on Reviews and New questions: M plan (A), N own answers (M).
- "10 easy reviews" on exam day: the 10 is a fixed cap (F, no source); "easy" is F (see finding).
- Overall accuracy % and the half ring: M; for CSE Professional A (weighted by area weights 5/30/35/30, source of weights to confirm); one answered area can set the whole value (F risk).
- Subject rows %: M (correct over answered, rounded).
- "N days" until exam, "N days from today" (date sheet): U date.
- Beta notice counts "N of 5 beta days", "7 short questions", "1 year of Pro": program rules (server counts M; 5 and 7 are program constants).
- Trial: days left, charge date and price (store entitlement P).
- Time minutes "10 min", "About 35 min": NOT shown (removed, correct).

Performance
- Overall accuracy and subject % as above (M, and A for CSE Professional).
- "N topics" per subject: P (content).
- "N answered", topic and lesson %: M. No minimum sample (a topic with 1 answer shows 0% or 100%): flagged minor.
- Wide web subject sub-line "N of M questions" (`subtextFor`, performance_provider.dart:350): N is M, size M is the published bank size (P, app content).
- Topic page: accuracy %, answered, "N of M lessons read": M and P.

Record
- Weeks in: M (ceil of days since first activity, at least 1).
- Day streak: A (streak_evaluator with freezes); shown without decay (flagged major). "since <date>": M, only when the history proves it.
- Questions answered: M but mock items are counted by paper size (flagged).
- Time in sessions: M by wall clock (flagged).
- Lessons read, Days active: M. Longest streak: A. Best mock %, mock % rows: M (raw correct over total).
- Accuracy across your prep: M weekly; "this week" label flagged major. "Your line starts after two weeks of answers": rule, wording flagged.

Tendencies
- Under pressure (practice % vs time %): M, gated by two-proportion test (A, named: TendencyStatistics).
- How long you answer ("38s" vs "52s", "+14s"): M, Welch test on log times (A).
- How you study ("79%" read first): M.
- How long you remember ("12d memory holds", "9% lapse rate"): A (FSRS stability and lapse rate, T3); stability is not stated as an exam outcome in the copy.
- Stamina: M, gated.
- When you work: "Peak hour" M but ungated (flagged); "Average session" and "Total sessions": M.
- Archetype name and line: F (cutoffs invented, T4; names approved on boards).

Plan
- "N days until <exam>": U date. "N of M done": M against the plan (A). Week and day lists: A (roadmap algorithm). "Oct 11 - 17" weeks: dates.
- History entries: stored facts only; no "7 to 8 a day" figure is invented (correct; see finding).



---

# SLICE C: Settings, paywall, Pro page, checkout, feedback, guardian, legal
# UI inspection findings, slice C: Settings (all sub-pages), Pro and paywall, dialogs and sheets

Policy read: `git show origin/main:AGENTS.md` and `docs/workflow/process-improvement.md` (origin/main 78a7d90a6). Code root: qa/cse-release-r1 worktree. Boards read from the exported handoff (web/project and mobile/project .dc.html, extracted text and inline styles). Read only; nothing built or run.

Notes on method and limits:
- Phone Pro, Settings and dialog boards are in `mobile/project/ST_*.dc.html`; wide web boards in `web/project/ST_*.dc.html`.
- The Feedback (Beta) boards live in a Claude Design canvas (https://claude.ai/artifact/Qomyc2zSW8ngMgwQieHbRL, plan 2026-11-07-beta-feedback-page.md line 7), not in the export, so they could not be compared line by line.
- Documented, Aedwon-approved deviations from the boards that I did NOT count as gaps: phone plan tiles one per row, tile radius 14, hero radius 22, hero eyebrow outside the hero (design/system/README D148, D126, golden-lock ruling); "No payment needed." under the web trial button, "Your Google Play plan keeps renewing..." line, sign-out wording "Your progress is saved to your account..." and hidden web Reminders/backup details (docs/superpowers/plans/new-design/STATUS.md line 1264, "Aedwon decisions").

### Pro page (phone): "Restore Purchases" is a 52 px full-width text button, board draws a plain 15/600 line
- Severity: major
- Evidence: lib/features/settings/presentation/pages/pro_page.dart:1047-1052 (PantasButton variant tertiary, no height override; lib/core/ui/components/pantas_button.dart:152 defaults height to PantasSize.btnPhone 52, minimumSize double.infinity x 52 at :293, label phoneHeadline 17/600); board mobile/project/ST_ProFree.dc.html (and ST_ProCSE, ST_ProCSEPass, ST_ProPending, ST_ProRestoreOffline): a `div` 15px/600 #0B7A68, line-height 1.35, `padding-top: 4px`, centered, no box; bar gap 8 between CTA, fine print and Restore
- Gap: board "Restore Purchases" occupies about 24 px (20.25 line + 4 top) at 15/600; code occupies 52 px tall x full width at 17/600. This is Aedwon's finding 3 on the money path. The bar is therefore about 28 px taller than drawn.
- Platforms: phone; Free (and Pro/lapsed, see next finding)
- Fix idea: add a `btn--text-phone-sm` size (15/600, about 24 px, hit area padded to 44 only if the board allows) and use it for Restore Purchases; design/system/components/Button/README.md line 39 already names it.

### Pro page (phone): bottom bar padding and spacing differ from ST_ProFree
- Severity: minor
- Evidence: pro_page.dart:979-984 `EdgeInsets.fromLTRB(16, 14, 16, 16)` inside SafeArea, children not separated by a gap (only `SizedBox(height: 8)` above the fine print at :1012/:1020, none before Restore at :1047); board ST_ProFree bar `padding: 14px 16px 30px`, `gap: 8px` between CTA, fine print, Restore
- Gap: bottom padding 16 (plus device safe area) vs 30; Restore sits directly under the fine print with 0 gap (its own 52 px box supplies the visual gap) vs 8 gap then a 24 px line.
- Platforms: phone; both
- Fix idea: set bar bottom padding 30 and a uniform 8 gap when the Restore line is converted (see previous finding).

### Pro page (phone, Pro and lapsed): Restore is a bottom-bar button, boards draw a list row with no bar
- Severity: major
- Evidence: pro_page.dart:1040-1052 (bar always holds Restore Purchases when not `upgrade`, even when `owned` or `lapsed`); boards mobile/project/ST_ProPro.dc.html, ST_ProPassHave.dc.html, ST_ProLapsed.dc.html: "Restore purchases" (lowercase p) is a 17/400 teal row inside the last card, below "Manage in Google Play"; no bottom bar except "Get Pro Again" on ST_ProLapsed
- Gap: a Pro student sees a floating bar with a 52 px "Restore Purchases" button; boards show a card row. Lapsed: board has the row AND the CTA bar, code has CTA and a 52 px Restore button.
- Platforms: phone; Pro (and lapsed Free)
- Fix idea: render Restore as a SettingsRow(teal) inside the plan card for owned and lapsed states, drop the bar when there is no CTA.

### Pro page (phone, Pending): "Open Google Play" is an inline text button, board draws the bar CTA
- Severity: minor
- Evidence: pro_page.dart:1257-1283 (PantasButton tertiary inside the "Waiting for your payment" card, 52 px); board ST_ProPending.dc.html: card has an envelope icon and a 17/600 title "Waiting for your payment"; "Open Google Play" is the 52 px filled primary in the bottom bar with "Restore Purchases" 15/600 under it
- Gap: card title is `context.type.emphasized` with no icon; CTA is a text button in the card, not the bar. Native only (`pending = web ? null`).
- Platforms: phone native; Free
- Fix idea: move the CTA to the bar and add the icon.

### Pro page (wide web): pending-payment state in the web board is not implemented
- Severity: minor
- Evidence: pro_page.dart:824 `final pending = web ? null : ...`; board web/project/ST_ProPending.dc.html: "Waiting for your payment / Monthly, ₱99. Pay in GCash or at the counter to finish. Pro turns on as soon as your payment is confirmed. / See Payment Steps"
- Gap: PayMongo web checkout redirects away and returns; there is no waiting card or "See Payment Steps" button. The in-app wait is only the button text "Confirming your payment" (:914).
- Platforms: wide web; Free
- Fix idea: needs a ruling: either drop the board state (PayMongo redirect model) or build it. needs a board update.

### Pro page (CSE): board shows Monthly and Season Pass only; code and pricing.md add Weekly and Yearly
- Severity: major
- Evidence: boards mobile/project/ST_ProCSE.dc.html title "Monthly ₱149 with 7 days free, or a ₱499 Season Pass; no weekly" and web/project/ST_ProCSE, ST_PassSoon, ST_PassNoDate, ST_PassEnded (two tiles); docs/pricing.md Civil Service row "₱49 weekly, ₱149 monthly, ₱1,199 yearly, or a ₱499 pass (weekly and yearly added by Aedwon, 6 October 2026)"; code lib/features/paywall/domain/products.dart `pantas_cs_weekly`, `pantas_cs_yearly`; pro_page.dart:720-730 shows every recognized package of the tier
- Gap: no board draws CSE Weekly ₱49, Yearly ₱1,199 (yearly would read "SAVE 32%" and "₱100 a month": 1199/12 = 99.9, rounded up by `.ceil()` at pro_page.dart:1442). HANDOFF "Known loose ends": Weekly/Yearly CTA and terms not designed.
- Platforms: both; Free
- Fix idea: needs a board for CSE with three plans plus Season Pass (and the Weekly/Yearly CTA and fine print); confirm the Play/PayMongo products exist.

### Pro page (phone): hero eyebrow and phone hero spacing vs board
- Severity: minor
- Evidence: pro_page.dart:1103 `Text('PANTAS PRO', style: sectionHeader)` plus 12 px gap, then PhoneProHero (phone_pro_hero.dart:33-45 radius 22, padding 26 x 22, perks gap 12, heading pageTitle); board ST_ProFree: "PANTAS PRO" is 13/700 white with a 20 px icon INSIDE the hero, hero radius 24, perk gap 12; lapsed/pro boards ST_ProLapsed, ST_ProPro, ST_ProPassHave draw no eyebrow at all
- Gap: eyebrow sits above the hero on every state including lapsed/owned (boards omit it there); ruled for Free in golden-lock-ruling.md ("move the eyebrow down inside the hero by one space-12 step"), which the code has not followed (it moved it outside). Also hero radius 22 vs 24 (README CHANGE).
- Platforms: phone; both
- Fix idea: follow the golden-lock ruling or record the move outside the hero as an approved change; drop the eyebrow on lapsed/owned.

### Pro page: "Loading subscriptions...", "Could not load your passes." and "Try Again" have no board and no styling
- Severity: minor
- Evidence: pro_page.dart:660 `const Text('Could not load your passes.')` and :661-664 PantasButton "Try Again" (unstyled Text, default text style); :1311 and :1398 `const Text('Loading subscriptions...')`; :1388-1394 and :1400-1404 secondary 52 px "Try Again". Board for loading/error: mobile ST_Error ("Could not load your topics." / "Try Again") and ST_Loading (pulsing shapes, "only if slow") are the Study states; L_Rules says "Most of Pantas runs on the phone and needs none of them" and "No percentages unless real".
- Gap: plain default-styled text with an ellipsis "..." (AGENTS voice uses none), not the StateView/skeleton the boards draw; the skeleton exists for owned passes (:641-653) but not for plan loading.
- Platforms: both; Free
- Fix idea: replace with the skeleton (plan tiles) and StateView; copy "Could not load your plans." needs a board for the Pro page error state.

### Pro page: purchase button labels and fine print for Weekly, Yearly and web
- Severity: minor
- Evidence: pro_page.dart:845-860 purchaseLabel: "Buy 1 Month for ₱149" (web), "Subscribe for ₱149 a Month" (native non-trial), "Upgrade for ₱149 a Month", "Get Pro Again", "Try 7 Days Free", "Buy Season Pass"; fine print only for trial (:1019-1031 "Then ₱149 a month. Cancel any time in Google Play." native; "No payment needed." web) and passes. L_Purchase board: "Subscribe for ₱99 a Month" then "Confirming with Google Play" then "You're Pro" / "Cancel any time. Billed through Google Play."; HANDOFF: "The CTA and terms for Weekly or Yearly selected aren't designed yet."
- Gap: when Weekly or Yearly (no trial) is selected there is no fine print line at all (board only draws one under the trial CTA and L_Purchase's "Cancel any time. Billed through Google Play."); web label "Buy 1 Month for ₱149" has no board. The in-button confirming text "Confirming your payment" (web, :914) differs from L_Purchase "Confirming with Google Play" and shows no "You're Pro" end state (the page just swaps to the owned hero).
- Platforms: both; Free
- Fix idea: needs a board for Weekly/Yearly/web CTA and terms, and the L_Purchase end state.

### Pro page (Pro, trial and lapsed states): trial wording and rows differ from ST_RootTrial and ST_ProLapsed
- Severity: major
- Evidence: pro_page.dart:751-757 planName "Monthly trial", :1210-1216 row title "Charges" (native) or "Ends" (web, `web ||`), :1083-1098 and :1114-1121 hero detail "Thanks for backing Pantas. Here's everything that's yours." in every owned state; board web/project/ST_RootTrial.dc.html: hero "You're on Pro." / "Your free trial ends in 3 days. Then ₱99 a month.", rows "Plan: Monthly, trial" and "Trial ends: Oct 17, 2026", button "Manage Subscription"
- Gap: during a trial the page never says how many days are left or what comes next (native: the Play charge date appears only as the row "Charges"; no price). Plan reads "Monthly trial" (board "Monthly, trial"); date row reads "Charges"/"Ends" (board "Trial ends"). The web trial footer "Your free trial ends on X. You won't be charged." is the approved web wording (STATUS.md 1264), but the hero detail is not trial-specific. Lapsed: web hero adds "Nothing was lost." (board) while phone omits it (phone board omits too: consistent). Lapsed list still shows "SAVE 32%" and "₱67 a month" on Yearly (pro_page.dart:1444-1451 does not check `lapsed`); boards ST_ProLapsed (phone and web) show no tag and no per-month line, and phone header "PLANS" not "PLANS FOR UPCAT" (:1293).
- Platforms: both; Pro (trial) and Free (lapsed)
- Fix idea: add a trial hero detail line from the entitlement end date, rename to "Monthly, trial" and "Trial ends", hide the SAVE tag and per-month line when lapsed, header "PLANS" on phone when lapsed.

### Pro page (wide web, Pro): no "Manage Subscription" and "Renews" per board; code says "Ends"
- Severity: minor
- Evidence: pro_page.dart:1208-1219 `web ... ? 'Ends'`, :1406-1412 "Manage in Google Play" is `!web` only; board web/project/ST_Pro.dc.html and ST_RestoreDone.dc.html: rows "Plan Monthly", "Renews Nov 4, 2026", button "Manage Subscription"
- Gap: PayMongo web plans are prepaid and never renew, so "Renews" and "Manage Subscription" are correctly absent, but the web boards were never updated; and Terms say access "does not renew". Phone board ST_ProPro says "Renews" and "Manage in Google Play" (native only, correct).
- Platforms: wide web; Pro
- Fix idea: update the web boards (Pro, RestoreDone) to the prepaid model; needs a board.

### Pro page: hard-coded "7" in every trial string, not read from the product
- Severity: minor
- Evidence: pro_page.dart:852 'Try 7 Days Free', :1448 '7 DAYS FREE', board fine print "Free for 7 days"; trial eligibility comes from `freePhase != null` (lib/features/paywall/data/revenuecat_sdk.dart:110) or the web server flag (web_payment_gateway.dart:315), never the length; Terms say "seven-day" (legal_document.dart:320)
- Gap: pricing.md confirms 7 days on Monthly only (Yearly and Weekly have none: code enforces `PaywallSku.monthly` at revenuecat_sdk.dart:110, web_payment_gateway.dart:631, pro_page.dart:744-749). If the Play offer length ever differs, the app still prints 7. Source class: decided (pricing.md), not read.
- Platforms: both; Free
- Fix idea: assert 7 in a test against the offer, or read the free phase length.

### Account (phone and web): header, spacing and weight
- Severity: minor
- Evidence: lib/features/settings/presentation/pages/account_page.dart:311-335 (avatar 84, gap 6, name `PantasType.phoneTitle2` 22/700 with a comment saying "24 px name", gap 10, email phoneExplanation 15), :338 and :355 `SizedBox(height: s20)` between blocks; board mobile/project/ST_Account.dc.html: avatar 84, name 24/700, email 15, header gap 8 / 8, `gap: 22px` between header and each card; settings_home_page.dart:277 root name phoneTitle2 22/700 vs ST_Root name 22/600
- Gap: name 22 vs 24 (ST_Account); block gap 20 vs 22; avatar to name 6 vs 8 and name to email 10 vs 8; root name weight 700 vs 600
- Platforms: phone; both
- Fix idea: set name style 24/700 on Account, 22/600 on the root card, gaps 8/8 and 22.

### Account (phone and web): extra rows and a button with no board
- Severity: minor
- Evidence: account_page.dart:170-175 and :402-404 "Continue with Email" (web only), :204-205 and :349-350 "Email" row instead of "Signed in with / Google" (web), :52 and :236, :359 row "I'm 18 now" with toast "Your account is now set for 18 and over." (:81) for minors; boards ST_Account, ST_AccountOut (phone and web) show only "Continue with Google" and "Signed in with / Google"
- Gap: three elements have no approved board; sources: email link sign-in is a pwa-launch decision (route /auth/email-link), age recheck is the guardian work; neither has a Settings board
- Platforms: both (web build only for the email items); both
- Fix idea: needs a board (Account with email sign-in and the minor's "I'm 18 now" row).

### Account (phone): Free signed-in user is told two different things about where progress lives
- Severity: minor
- Evidence: account_page.dart:424-425 phone Free footer "Your progress stays on this phone only. With Pro, it's backed up and syncs across your devices." and :541-542 sign-out dialog "Your progress is saved to your account. It comes back when you sign in again."; boards mobile ST_Account and ST_SignOut: "Your progress stays on this phone. Sign in again any time."; web board ST_SignOut "Your progress stays in this browser. Sign in again any time."
- Gap: sign-out copy was ruled by Aedwon for the web (STATUS.md 1264, "keep sign-out wipe"), and web Free does sync answers (webFreeBackupNote). On a phone build, Free backup is "This phone only", so "saved to your account" contradicts the row above it and sign-out wipes local data. Confirm the Free phone claim is true before release.
- Platforms: phone native; Free
- Fix idea: needs a ruling for native Free; web wording stands.

### Backup page: single row and a 52 px filled "Back Up Now"; boards draw a detail list and states
- Severity: minor
- Evidence: backup_page.dart:129-153 one "Backup" row, constant footer "Pantas backs up on its own whenever you're online.", PantasButton "Back Up Now" / "Try Again" (52 px, primary, full width), no "Sign In to Back Up"; label composite "Saved today, 7:12 PM" (:44-54); boards mobile ST_BackupDetails ("Last backed up", "Waiting to back up", "Backed up since", "This phone", "Back Up Now" as a teal list row), ST_BackupStates (footers "This takes a moment. You can keep using Pantas.", "It backs up when you're back online.", "Your progress is safe on this phone.", "Pro backs up your progress once you sign in." and "Sign In to Back Up"), ST_BackupNowOffline ("You need a connection to back up."); account row value "Saved" with separate "Last backed up" row (ST_AccountPro)
- Gap: Aedwon's Nov 8 comment in code ("one row and one footer in every state, nothing moves") explains the reduction, but the offline note, the Pro-not-signed-in state and the "Sign In to Back Up" row from the boards are missing, and Backup page button is a filled 52 px button where the board draws a list row. No "Waiting to back up" or "Backed up since" figures (these would be measured, so allowed).
- Platforms: both (web hides details, STATUS 1264); Pro
- Fix idea: confirm the Nov 8 reduction supersedes ST_BackupDetails; add the offline and not-signed-in states; needs a board refresh.

### Delete account (phone): "Deleting..." and "Deletion request completed." text; no steps screen
- Severity: major
- Evidence: delete_account_page.dart:371-386 plain `Text('Deleting...', style: body)` and `Text('Deletion request completed.')` under the card on the phone; wide path uses `StepsScreen` (:100-120) with ONE step "From this browser and the cloud" and done title "Your account is deleted." (no second sentence); boards mobile/project/L_Delete.dc.html: "Deleting your account / Keep Pantas open until this finishes." with two stages "From this phone: Answers, notes, plan history" and "From the cloud: Backup and sign-in", done "Your account is deleted. Nothing of yours is left." and a "Close" button; L_Rules.dc.html: deleting the account is a full-screen steps screen
- Gap: phone shows no steps screen at all, voice differs ("Deleting..." and "Deletion request completed." instead of "Deleting your account" and "Your account is deleted. Nothing of yours is left."), wide merges the two board stages and drops the last sentence. The "Delete" button also stays on the page during deletion (busy 52 px button).
- Platforms: phone and wide web; Free and Pro
- Fix idea: use StepsScreen with the two board stages on both widths and the board's done copy.

### Delete account (wide web): "Deleting" screen does not tick the real stages
- Severity: minor
- Evidence: delete_account_page.dart:100-120 `steps` holds one active step and none in the done state (`if (!_isDeleted)`), button label null while deleting; L_Rules.dc.html: "A full screen listing the real stages, ticking off as each finishes."
- Gap: nothing ticks off; the done screen shows no completed steps.
- Platforms: wide web; both
- Fix idea: list the two board stages and tick them as the account and local deletions finish.

### Reminders (phone native): the row opens a route that does not exist; no Reminders page is built
- Severity: major
- Evidence: lib/features/settings/presentation/settings_home_page.dart:333-347 pushes '/settings/reminders' when `!kIsWeb`; no route for it in lib/app/routes/settings_routes_native.dart or settings_routes_web.dart (grep finds the string only in the row); no reminders page file under lib/features/settings/presentation/pages; lib/features/notifications/presentation/permission_rationale_page.dart is not referenced anywhere; boards mobile ST_Reminders, ST_RemindersOff, ST_RemindersOffSwitch (and web twins) draw the page
- Gap: on an Android or iOS build the Reminders row leads to a router error; web hides the row (docs/superpowers/plans/new-design/STATUS.md line 42 "hide web Reminders", line 1264 "Task 1 reminders parked, native only"), so the wide boards that show a Reminders row (all web ST_* lists) differ.
- Platforms: native phone (broken); wide web and PWA phone hide it; both
- Fix idea: hide the row until the page ships, or build it from ST_Reminders.

### Notifications: permission rationale page is unrouted dead code
- Severity: minor
- Evidence: lib/features/notifications/presentation/permission_rationale_page.dart:59-80 "I'll be your coach." / "Get one daily study reminder and a streak-save warning when you still have work left today." / "Sounds good" / "Not right now" (tertiary, 52 px); no import of the class in lib (grep), onboarding board OB_Permission exists
- Gap: not reachable; copy and "streak-save warning" are not in any board (OB_Permission is the onboarding step, another slice).
- Platforms: native phone; both
- Fix idea: delete or route it per OB_Permission.

### About: rows and copy beyond the board; version string
- Severity: minor
- Evidence: lib/features/settings/presentation/pages/about_page.dart:28-35 "Help improve Pantas by sharing usage data" (ST_About: "Help improve the app"), :29-34 extra toggle "Send speed and error reports" with subtitle "Helps us find slow screens and errors." or "Helps us fix slow screens and errors. Includes screen counts.", :226-239 the DPO address printed under the row, :163-168 "Privacy Policy" / "Terms of Service" (boards "Privacy policy" / "Terms of service"), :41 and :108 `Version 0.1.0 (<build number>)`; board mobile/project/ST_About.dc.html and web ST_About: "Version 1.0.0 (142)", a note "Help improve the app shares anonymous usage data. Crash reports are always sent. Contacting the officer opens your mail app.", "Shared links 2"
- Gap: sources found: usage-data copy approved Nov 2 (code comment), speed reports from spec 2026-11-07-load-speed-and-telemetry-design.md and the usage telemetry log; the visible DPO email and the missing board note are not on any board; "Shared links" row is not built (the `sharedLinksRow` slot is never passed, about_page.dart:44, 218); "0.1.0" is a hard-coded default that duplicates pubspec.yaml and shows a pre-1.0 number
- Platforms: both; both
- Fix idea: needs a board for the Your data section as built; read the version from the package.

### Appearance and Practice: small copy and control differences
- Severity: minor
- Evidence: appearance_page.dart:124 "Automatic follows your phone's light or dark setting." and :48 wide "Automatic follows your computer's light or dark setting."; boards ST_Appearance: "Automatic follows your phone: light by day, dark at night."; appearance_page.dart:73-76 wide footer adds "⌘ + and ⌘ − still zoom the whole page." (no board); header "Lesson Text Size" (:73, :174) vs board "TEXT SIZE"; session_building_page.dart:119-122 strict footer says "Leaving the mock" on wide, "the app" on phone (matches both boards)
- Gap: the board sentence "light by day, dark at night" is wrong about how Automatic works (it follows the OS), so the code is the safer text; the header and the web zoom sentence are unspecced additions (source for the header: design-system D190 item 11 "Lesson Text Size")
- Platforms: both; both
- Fix idea: record approval of the corrected sentences; needs a board refresh.

### Practice and Exam pages: no gaps found beyond spacing between stacked buttons
- Severity: minor
- Evidence: carry_over_prompt.dart:750-770 bar `bottom: 30, left/right 16` with "Count Them" and "Start My Numbers Fresh" in a Column with no gap; board ST_ExamSwitch bar `padding: 14px 16px 30px; gap: 8px`; exam_page.dart:235-251 "Change Exam Date" (primary 52) and "Done" (tertiary 52) with no gap; board L_ChangeExam2 `gap: 6px`
- Gap: gap 0 vs 8 (ExamSwitch) and 0 vs 6 (ChangeExam2)
- Platforms: phone; both
- Fix idea: add the 8 and 6 px gaps.

### Beta items in Settings: "Beta: Pro Features" switch, note date and BETA mark
- Severity: minor
- Evidence: lib/features/settings/presentation/widgets/beta_pro_row.dart:67,80,97 "Beta: Pro Features", :86 "Turning On…", :42 toast "Could not change Pro features. Try again."; :126-127 "Pro features are on for the beta, until Nov 23." hard-coded while `BetaProState.until` exists (lib/features/paywall/application/beta_pro_provider.dart:10); board docs/superpowers/plans/pwa-launch/boards/beta-pro-switch-v1.html says the row disappears at 00:00 Nov 16 (since extended); settings_home_page.dart:53 'BETA' mark and :172 semantics "Feedback, beta"
- Gap: the date in the note is a constant, not the server value; boards use "Pro features" with no date; "…" ellipsis characters in "Turning On…" break the no-ellipsis voice
- Platforms: both; Free
- Fix idea: derive the date from `until`; remove all beta rows and the note for the CSE release (see G4 list).

### Feedback (Beta) pages: no approved board in the export; copy and structure
- Severity: minor
- Evidence: lib/features/beta_feedback/presentation/feedback_page.dart:58-62 "Count 5 days from Nov 9 to 22 and send the exit survey to earn 1 year of Pro." (hard-coded dates, no board available), :121 "Could not load your days." with a "Try again" tertiary (lowercase "again", :126-130, 52 px min height, no board), :78 "SEND FEEDBACK"; compose_card.dart:140-141 "Use a PNG, JPEG or WebP image." / "Each image must be 5 MB or smaller.", :211 hint "What worked, what broke, what you would change", :272 "Send Feedback", :276 key hint "⌘ Enter" / "Ctrl Enter"; reward_card.dart:163 "You earned 1 year of Pro", :226 "Activate 1 Year of Pro"; exit_survey_page.dart:143 "Exit Survey", :113 "The survey is closed.", :161 "Could not load the survey.", :282 "Send Survey"; survey_sent.dart:123 "Survey sent", :155 "Back to Feedback"
- Gap: spec docs/superpowers/specs/2026-11-07-beta-feedback-page.md says screens match the approved board 1:1; the board is a Claude Design canvas (https://claude.ai/artifact/Qomyc2zSW8ngMgwQieHbRL) not in the export, so I cannot verify spacing. Visible issues without it: "Try again" is not Title Case like every other "Try Again"; dates "Nov 9 to 22" are literals; the page is in the CSE release but is beta-only.
- Platforms: both; Free and Pro (testers only: `betaFeedbackVisibleProvider`)
- Fix idea: needs a board (export it); remove or gate the whole feature after the beta ends.

### Dialogs on Settings: whats-included tier dialog and sync gate have no board
- Severity: minor
- Evidence: whats_included_page.dart:246-262 CenteredDialog "<exam> becomes a <level> exam" / "Your <plan> plan does not cover <level> exams, so unlimited mocks, days ahead in your plan and Pro study figures stop on <exam>. Wrong-choice notes stay on questions that <level> exams also use." / "See Plans" / "Undo Change"; sync_reconciliation_gate.dart:32-36 CenteredDialog with `syncKeepMyAccount`; boards mobile/project/ST_Included*.dc.html show no dialog
- Gap: phone dialog buttons are the board's 46 px pill pair (CenteredDialog, centered_dialog.dart:182-254 height btnBar 46, matches ST_SignOut), so button sizing is faithful; the copy has no board. "days ahead in your plan" is Pro-only wording that is not on any Pro board.
- Platforms: both; Free and Pro
- Fix idea: needs a board for the tier-change dialog.

### Guardian pages (Confirm, Waiting, Manage, Withdrawn, contact): no approved board in the export
- Severity: minor
- Evidence: lib/features/guardian/presentation/guardian_waiting_page.dart:160-182 three stacked 52 px buttons "Check Again" (secondary), "Resend Email" and "Change Email" (tertiary, 52 px each) plus a notice line; guardian_confirm_page.dart:236-246 "Confirm" and "I Don't Agree" (tertiary critical 52 px); guardian_manage_page.dart:292-304 wide "Withdraw" (tertiary red, height 42, padding 20 shifted -18); dialog "Withdraw"/"Cancel" at :121-130; `grep -il guardian` over web/project and mobile/project returns no board; spec 2026-11-11-withdrawn-account-gate.md
- Gap: no board to compare; the two borderless 52 px buttons on Waiting add 104 px of button area (finding 3 pattern)
- Platforms: both; both
- Fix idea: needs a board.

### Legal documents: title case, Terms trial text vs native Play trial
- Severity: minor
- Evidence: lib/features/legal/presentation/legal_document_page.dart:37-39 and :234-236 title "Privacy Policy" (board mobile/project/ST_Privacy.dc.html "Privacy policy"), :87,141,163 "Updated Nov 11, 2026" (board "Updated Aug 3, 2026" sample); lib/features/legal/domain/legal_document.dart:320-328 "Free trial. You can get one seven-day free trial of Monthly Pro... You do not enter payment details... we do not charge you." and :304-306 "Weekly access lasts seven days... These plans give Civil Service Pro access."
- Gap: the Terms text describes the web prepaid trial and says no charge; the native Play trial charges ₱149 after 7 days (home_notices.dart:276-289 "Google Play charges ... to keep Pro") and the Terms' "These plans give Civil Service Pro access" sentence is web-specific and does not describe the native Student plans. On web this is consistent with pricing.md.
- Platforms: native phone for the trial clash; both for the casing
- Fix idea: a native clause for the Play trial (policy rule 5: an agent drafts, Aedwon checks).

### Home notices for trial and welcome (HM_Trial, HM_ProWelcome): wording differs from the boards
- Severity: minor
- Evidence: lib/features/home/application/home_notices.dart:65-68 title "Pro trial ends in N days"; :271-288 native detail "Google Play charges ₱149 on Oct 16 to keep Pro. Cancel any time before then." (board web/project/HM_Trial.dc.html: "You'll be charged ₱99 on Oct 16 to keep Pro. Cancel any time before then."), buttons "Manage"/"Got It" (board "Got It" and "Manage"); web path :75-84 "Your free trial ends on X. You won't be charged." with "See Pro" / "Got It" (approved proposal v1 24 Oct per the code comment); :296-306 "You're in. Welcome to Pro." / "Topics, lessons and your tendencies are open now." / "See What's New" / "Got It" (matches HM_ProWelcome)
- Gap: native sentence starts "Google Play charges" not "You'll be charged"; the web notice swaps "Manage" for "See Pro" and drops the price (intentional, no charge)
- Platforms: both; Pro (trial)
- Fix idea: confirm the approved wording; "Got It" is the secondary text button (see inventory).

### Pro page (wide web): Restore Purchases and Switch on Free are 44 px with padding 20 where the board draws 42 px and 14
- Severity: minor
- Evidence: pro_page.dart:880-897 `Transform.translate(offset: (-14, 0))` around `WebButton(variant: tertiary)` (size standard: 44 high, side padding 20, lib/core/ui/components/pantas_button_spec.dart "standard" metrics); board web/project/ST_Paywall.dc.html and ST_ProCSE: `<button class="btn3" style="margin: 4px 0 0 -14px">` with `.btn3 {height: 42px; padding: 0 14px}` (web/shared/pantas.css:73)
- Gap: board label starts at x = 0 (margin -14 plus padding 14) and the box is 42 high with a 4 px top margin; code label starts at x = +6 (translate -14 plus padding 20) in a 44 px box with no top margin: 6 px right, 4 px high, 2 px taller
- Platforms: wide web; Free (and Pro, where Restore is the only action)
- Fix idea: translate by -20 or use the 42/14 `btn3` size; add the 4 px top margin.

### Settings wide web: Account "Sign Out" and "Delete Account" start 6 px later than the board
- Severity: minor
- Evidence: account_page.dart:274-292 `WebTextAction` (size sm: 42 high, padding 18) and `WebButton` tertiary (height 42, padding 20) inside `Padding(horizontal 4)` and `Wrap(spacing 8)`; board web/project/ST_Account.dc.html: `<div class="hrow" style="gap: 8px; padding: 0 4px">` with `.btn3` (42 high, padding 14)
- Gap: label x = 4 + 18 = 22 ("Sign Out") and 4 + 20 + 8 + label for the second vs board 4 + 14 = 18; each button is 6 to 8 px wider than drawn (hit area larger, the visible hover wash too)
- Platforms: wide web; both
- Fix idea: use the 42/14 `btn3` metrics for these two.

### Dialogs (phone): sign-out, withdraw and tier dialogs match the 46 px pill pair; no borderless button there
- Severity: minor
- Evidence: lib/core/ui/components/centered_dialog.dart:182-254 `PantasButton(height: PantasSize.btnBar)` in a `ButtonPair`, neutral Cancel and filled primary; board mobile/project/ST_SignOut.dc.html `height: 46px; border-radius: 99px; background: #EDEDF0` for Cancel and `#0B7A68` for Sign Out, gap 10, dialog padding 22/20/18, gap 8, margin-top 12
- Gap: none found for the pair itself. The wide dialog's Cancel is a 44 px `WebButton` tertiary (centered_dialog.dart:150-156) where board web ST_SignOut draws `.btn3` 42 px; same 2 px / 6 px difference as above. Sign-out copy differs (see Account).
- Platforms: both; both
- Fix idea: none for phone; align wide dialog Cancel to 42/14.

## Button inventory (finding 3)

Borderless or text buttons in this slice. Board value is measured from the board's inline style. "Hit area" is the pressable box (full width means the button stretches across the content width).

| Widget | file:line | Height | Padding | Hit area | Board value | Flag |
|---|---|---|---|---|---|---|
| Restore Purchases (phone Pro bar) PantasButton tertiary | lib/features/settings/presentation/pages/pro_page.dart:1047-1052 | 52 min (pantas_button.dart:152, :293) | horizontal 20, vertical 8, label 17/600 | full width x 52 | plain 15/600 text line, `padding-top: 4`, about 24 high (ST_ProFree, ST_ProCSE, ST_ProPending) | YES, 28 px taller than drawn; Pro and lapsed boards draw a card row instead |
| Switch on Free (phone upgrade) PantasButton tertiary | pro_page.dart:1040-1045 | 52 | 20 / 8 | full width x 52 | 52 x 100%, transparent, 17/600 (mobile ST_SwitchUpgrade) | no |
| Open Google Play (phone pending card) PantasButton tertiary | pro_page.dart:1275-1279 | 52 | 20 / 8 | full width x 52, inside a 16 px padded card | filled 52 CTA in the bar (ST_ProPending) | YES, wrong kind and place |
| Restore Purchases / Switch on Free (wide) WebButton tertiary | pro_page.dart:880-897 | 44 | 20 each side, translated -14 | label + 40 wide x 44 | `.btn3` 42 high, padding 14, margin 4 0 0 -14 (web ST_Paywall) | yes, 2 high, 6 px right, 4 px high |
| Try Again (Pro load error) PantasButton secondary | pro_page.dart:661-664, :1388-1394, :1400-1404 | 52 | 20 / 8 | full width | none (no board) | needs a board |
| Keep My Account / Cancel (phone Delete) PantasButton tertiary | delete_account_page.dart:276-282 | 52 | 20 / 8 | full width x 52 | 52 x 100%, transparent 17/600 (mobile ST_DeleteAccount) | no |
| Keep My Account / Cancel (wide Delete dialog) WebButton tertiary | delete_account_page.dart:197-202 | 44 | 20 | label + 40 x 44 | `.btn3` 42 / 14 (web ST_DeleteAccount) | minor (2 px, 6 px) |
| Sign Out / Delete Account (wide Account) WebTextAction, WebButton tertiary red | account_page.dart:279-292 | 42 | 18 and 20 | label + 36 / 40 x 42 | `.btn3` 42 / 14 | minor (+4 and +6 px width) |
| Delete My Data (signed-out, wide) WebButton tertiary critical sm | account_page.dart:243-251 | 42 | 18 | label + 36 x 42 | none (ST_AccountOut has no delete row) | needs a board |
| Dialog Cancel (phone) CenteredDialog neutral | lib/core/ui/components/centered_dialog.dart:182-254 | 46 | 12 | half the pair x 46 | 46, filled #EDEDF0, radius 99 (ST_SignOut) | no (filled, not borderless) |
| Dialog Cancel / Undo Change / Keep My Account (wide) WebButton tertiary | centered_dialog.dart:150-156 | 44 | 20 | label + 40 x 44 | `.btn3` 42 / 14 (web ST_SignOut) | minor |
| Start My Numbers Fresh (phone) PantasButton tertiary | carry_over_prompt.dart:766-770 | 52 | 20 / 8 | full width x 52 | 52 x 100% transparent (ST_ExamSwitch), gap 8 | gap 0 vs 8 only |
| Start My Numbers Fresh (wide) WebButton tertiary | carry_over_prompt.dart:437-441 | 44 | 20 | label + 40 x 44 | `.btn3` 42 / 14 (web ST_ExamSwitch) | minor |
| Done (phone, after exam change) PantasButton tertiary | exam_page.dart:246-250 | 52 | 20 / 8 | full width x 52 | 52 x 100% transparent (L_ChangeExam2), gap 6 | gap 0 vs 6 only |
| Study-day circles TextButton | exam_page.dart:295-312 | 44 (`PantasSize.targetTouch`) | 0 | 44 x 44 circle | 44 circle (ST_Exam) | no |
| Resend Email, Change Email PantasButton tertiary | lib/features/guardian/presentation/guardian_waiting_page.dart:172-182 | 52 each | 20 / 8 | full width x 52 each | none (no guardian board) | needs a board; 104 px of text-button height |
| I Don't Agree PantasButton tertiary critical | guardian_confirm_page.dart:241-246 | 52 | 20 / 8 | full width x 52 | none | needs a board |
| Withdraw (wide) WebButton tertiary red | guardian_manage_page.dart:297-304 | 42 | 20, translated -18 | label + 40 x 42 | none | needs a board |
| Try again (Feedback days error) PantasButton tertiary | lib/features/beta_feedback/presentation/feedback_page.dart:125-131 | 52 (phone size; `fullWidth: false`) | 20 / 8 | label + 40 x 52 inside a card | none (board not exported) | inflates the error card to about 84 px; lowercase "again" |
| Not right now PantasButton tertiary | lib/features/notifications/presentation/permission_rationale_page.dart:77-81 | 52 | 20 / 8 | full width x 52 | OB_Permission (other slice) | unrouted |
| Back links ("Settings", "Account", "Back") WebBackLink / PantasPage back row | lib/features/settings/presentation/widgets/settings_pane_page.dart:96-102 (phone, 4 px edge) ; legal_document_page.dart:226-229 | 44 phone back row | left 4 | label + chevron x 44 | `padding: 6px 8px 0 4px; height: 44px` (ST_ProFree, ST_Account) | no |
| Got It / Manage / See Pro / Later (Home notices, wording in this slice) | lib/features/home/application/home_notices.dart:75-84, :271-289, :296-306 | drawn by the Home notice (other slice) | n/a | n/a | `.btn3` "Got It" (web HM_Trial) | measured by the Home inspector |

Summary: the only button in the slice that occupies visibly more space than its board is the phone "Restore Purchases" (52 x full width where the board draws a 24 px text line). Everything else that is borderless on a phone is a 52 px full-width text button that the boards also draw at 52. The Waiting (guardian) and Feedback error buttons have no board.

## Figures (P10)

Every number a student can see in this slice and where it comes from. Classes: measured (from their own use), published (testing body or the store price list), named algorithm, decided (a recorded product rule), invented.

| Figure | Where shown | Source and class |
|---|---|---|
| ₱49, ₱149, ₱1,199 (CSE Weekly, Monthly, Yearly), ₱499 (CSE pass) | Pro page, Terms | `docs/pricing.md` Civil Service row; web prices in functions/src/products.json `webPricePhp` 49, 149, 1199, 499 match; native prices come from the store at run time. Published (decided), verified equal |
| Student prices ₱29, ₱99, ₱799 | Pro page for student exams | Store at run time; docs/pricing.md matches. Not sold on web (no `webPricePhp`) |
| "7 DAYS FREE", "Try 7 Days Free", "Free for 7 days" | Pro page | Decided (pricing.md: Monthly only). The `7` is a literal in pro_page.dart:852, :1448, :947, not read from the store offer. Trial gate is Monthly only in code (revenuecat_sdk.dart:110; web_payment_gateway.dart:631) |
| "SAVE 32%" (Yearly) | Pro page | Arithmetic on two published prices: floor(1 - yearly / (monthly x 12)), pro_page.dart:1435-1437. Student 799 vs 99: 32.7 shown 32. CSE 1199 vs 149: 32.9 shown 32. Floor means it never overstates. Named formula, not a measurement |
| "₱67 a month" on Yearly (CSE would read ₱100) | Pro page | price / 12 rounded up, pro_page.dart:1439-1443. 799/12 = 66.6 shown 67; 1199/12 = 99.9 shown 100. Arithmetic on a published price. No board for CSE (see finding) |
| "Ends in N days", "Ends today", "Until Mar 1, 2027" | Season Pass tile | Published exam sitting last day (`publishedSittings` with a source URL, pro_page.dart:390-403); the tile is disabled when none |
| "Trial, N days left" | Settings root | Entitlement end date minus now, ceil, clamped 0 to 7 (settings_providers.dart:228-250). Measured from the entitlement |
| "Renews"/"Charges"/"Ends" dates | Pro page | Entitlement dates from RevenueCat or the web grant ledger. Measured |
| "Waiting for your payment" amount | Pro page native | Package price from the store |
| "N questions" / "All questions" (Practice row) and 5, 10, 20, All | Settings root, Practice | The student's own setting. Choice values 5, 10, 20 are from ST_Practice |
| Reminder time (7:00 PM style) | Settings root | The student's own setting (native only) |
| Pantas ID 482 139 075 style | Account | Server-issued 9 digits, formatted `3 3 3` |
| "Saved today, 7:12 PM" | Account and Backup | Last successful sync time. Measured |
| "Version 0.1.0 (build number)" | About | Hard-coded default `0.1.0` (about_page.dart:41, equals pubspec.yaml version) plus the build number from CI (`BUILD_NUMBER`, build_info.dart:7). Build number published, version a constant |
| "N of 5 days" | Settings Feedback row and Feedback page | Days counted by the server (min(5, count), settings_home_page.dart:39). Measured; the 5 is the reward rule (decided Nov 7, spec 2026-11-07-beta-feedback-page.md) |
| "Nov 9 to 22", "until Nov 23", "Opens/Until <date>", "Activate by <date>" | Feedback, Beta row note | Decided dates, hard-coded (feedback_page.dart:59, beta_pro_row.dart:127); the survey and activation dates come from the server reward object |
| "1 year of Pro", "Pro for 12 months", "1 Year" | Feedback reward | Decided reward (spec Part A) |
| Survey scales "1 to 5", "0 to 10", "Every day / Most days / A few days / Once" | Exit survey | Question instrument from the spec; not statistics |
| "Each image must be 5 MB or smaller", "N of 3" images | Feedback compose | Product limits (spec: 5 MB, 3 images); `_maxImages` constant |
| "Updated Nov 11, 2026" | Legal pages | Constant `DateTime.utc(2026, 11, 11)` in legal_document.dart:40, :263, :494, the document's own date. Published |
| "seven days", "one calendar month", "₱1,000" liability cap | Terms | Legal text drafted under process rule 5 |
| Review-prompt thresholds (80% accuracy, 24 hours) | Never shown | Internal constants (review_eligibility.dart:5, :11), explicitly not printed. Not a figure issue |

Invented figures found: none printed. Two literals that look measured but are constants: "0.1.0" and the beta dates.

## Not covered or not verifiable

- Dark mode (DK_Settings) was not compared; light tokens only.
- Wide-web Settings list pane and wide Pro hero measurements beyond the items above were not re-measured px by px.
- Feedback (Beta) boards are not in the export; compare against the canvas link is needed.
- Guardian, notifications rationale, tier-change dialog, Account email sign-in and minor rows have no board in the export.



---

# SLICE D: Mock exam
# UI-2 findings D: Mock Exam (cse-pro, cse-sub; Free and Pro; phone and wide web)

Policy commit used: origin/main 78a7d90a6350879da9dd0952f8c5f51c0a432e3a (AGENTS.md, process-improvement.md rules 1-4). Code: branch qa/cse-release-r1 (same app code as prod web). Read-only; no builds run.
Platform routing fact: web (kIsWeb, `mockUsesServerProvider`, `lib/features/mock_exam/application/server_mock_results_providers.dart:12`) runs the server mock (`ServerMockRoute`); native phone runs the local mock (`MockStartRoute`). Both render the same `MockSessionPage`, `PausePage`, `PartTransitionPage`.

### Setup to run (phone native): a second "Start the Paper" screen after setup's Start
- Severity: major
- Evidence: lib/features/mock_exam/presentation/pages/mock_start_route.dart:858-872 (builds `MockStartPreparationPage` while `_controller == null`); mock_start_preparation_page.dart:75, 115, 122 ("Setting out your paper", "Your paper is set. The clock starts when you tap.", button "Start the Paper"); HANDOFF.md Hard rules: "There is no pre-mock 'Start' screen (L_MockStart was removed)"; board mobile/MK_SetupCSE.dc.html (setup holds the only Start: "Start the Mock Exam" and "The clock starts when you tap."); mobile/L_Rules.dc.html lists "Setting out a mock paper" as a steps screen, but no board draws a second Start gate.
- Gap: after "Start the Mock Exam" the native app shows a page with a 56 px timer tile, one row per section ("N questions" each) and a second Start button. It prints the clock-start promise twice and needs two taps. It also prints `blueprint.name` ("CSE Professional Practice Paper · 155 questions") instead of "CSE Professional simulation". Wide web (server mock) has no such page, so phone and web differ.
- Platforms: phone native only; Free and Pro
- Fix idea: keep at most the L_Rules "steps" beat while sampling, then start the clock without a second button. Needs a board for the steps screen (none exists).

### Setup (both): header, counts and unrequested lines versus MK_SetupCSE
- Severity: major (figures), minor (spacing)
- Evidence: mock_setup_page.dart:145-147 and 426-428 (`'$plannedTotal total items · ${_duration(...)}'`); mock_setup_page.dart:171-188, 316-323 ("The real exam also has N personal-information items. They are not scored, so this mock leaves them out."); content/mock/cse-pro.yaml sourceNote; board mobile/MK_SetupCSE.dc.html text "170 total items · 3 hr 10 min", rows 45/45/40/40, "counts are placeholders until sourced".
- Gap: (1) Board shows "170 total items" and 45/45/40/40; code shows "155 total items · 3 hr 10 min" and 20/55/35/45 for cse-pro (so the board is superseded by the Oct 19 data; yaml says Aedwon chose to show test items only). (2) For cse-sub the code shows "145 total items · 2 hr 40 min" with rows 36/36/36/37 (even-split placeholder, ruled DO LATER, decisions/2026-11-17-fable-backlog-rulings.md A17) and "The real exam also has 20 personal-information items...". Nothing on the page tells the student these counts are unconfirmed. (3) The personal-information line is in no board; source is the Oct 19 Aedwon choice recorded in the yaml sourceNote, not a board. (4) Board setup has no `mockPracticeLabelFor` subtitle line; it is only emitted when the blueprint name contains the Pantas practice label (cse names do not), so inert for CSE.
- Platforms: both; Free and Pro
- Fix idea: confirm with Aedwon whether 155/145 and "personal-information" line stay (a board covering CSE with the new figures is missing: "needs a board"); for cse-sub add the unconfirmed-count honesty rule from AGENTS.md "Never invent a figure".

### Setup (phone): small spacing differences versus MK_SetupCSE
- Severity: minor
- Evidence: mock_setup_page.dart:154 (`SizedBox(height: s24)` between title block and table), 157-162 (rule text padding top 8), 263-267 (bottom bar padding 16/14/16/32); board mobile/MK_SetupCSE.dc.html: content `gap:22px`, rule text `padding:7px 16px 0`, bottom bar `padding:14px 16px 30px`. The back link row (L4 T6 R8, 44 high, icon-label gap 2) matches the board.
- Gap: table gap 24 vs 22; rule-text top 8 vs 7; bar bottom padding 32 vs 30 (all 1-2 px). Strict card padding 16/12 matches the board (12px 16px).
- Platforms: phone; both
- Fix idea: use 22/7/30. Low value; fold into any setup change.

### Setup/Results/Resume (both): the exam is named three different ways
- Severity: major
- Evidence: domain/mock_title.dart:1-11 (doc comment: "The name every mock screen gives an exam's simulation"; returns "CSE Professional simulation"); application/mock_results_providers.dart:241-246 (`serverMockExamName` returns "CSE Professional", used for web results, line 261); mock_start_route.dart:226 and mock_results_route.dart:203 (native results title is `attempt.blueprintName` = "CSE Professional Practice Paper", the yaml `name`); widgets/mock_resume_sheet.dart:32 (dead); boards mobile/MK_Results, web/MK_ResultsFirst ("UPCAT simulation").
- Gap: board names the results screen "<Exam> simulation". Setup, run header and Quiz card say "CSE Professional simulation". Native results (and the finale title) say "CSE Professional Practice Paper"; web results say "CSE Professional". Same for cse-sub ("CSE Subprofessional Practice Paper" / "CSE Subprofessional").
- Platforms: both (different wrong names on each); Free and Pro
- Fix idea: route results and finale titles through `mockSimulationTitle`.

### Session (phone): proctor call is a layout-shifting toast that stays 8 s; board is a 2.5 s overlay
- Severity: major
- Evidence: presentation/proctor_toast.dart:17 (`proctorToastDisplayDuration = Duration(seconds: 8)`); pages/mock_session_page.dart:158-166 and 253-262 (status is a Padding in the Column between the question list and the bar, so the list shrinks while it shows); proctor_toast.dart:59-72 (container, radius r2xl, padding v10, card surface); board mobile/MK_Proctor.dc.html title "sits above the bar for 2.5 seconds with three short buzzes, then goes", element `position:absolute; left:16; right:16; bottom:98px; height:44px; border-radius:22px`.
- Gap: board 2.5 s, absolute overlay above the bar, 44 high pill. Code 8 s (wide web uses 2.5 s, mock_session_page.dart:197-199), in-flow so the question list jumps up by about 48 px when it appears and down when it leaves, height about 40. The haptic (3 buzzes) matches.
- Platforms: phone; Free and Pro
- Fix idea: overlay it (Positioned) at 2.5 s, 44 high, radius 22.

### Session (both): proctor wording "in this subject" on a one-block paper
- Severity: minor
- Evidence: proctor_toast.dart:12-15 (`'$minutes $unit left in this subject.'`); mock_session_page.dart:902-903 (wide header caption uses the same string); boards mobile/MK_Proctor, MK_FiveMin, MK_LastMinute (UPCAT, parts); web/MK_Proctor ("10 minutes left in this subject", no period, in a pill).
- Gap: CSE is one block with one clock and no subjects timed apart (cse-pro.yaml sectionalTiming: roamable). "In this subject" names a clock that does not exist. No CSE proctor board. Wide board has no trailing period and draws a gray pill (bg #EDEDF0, padding 2/9, 12/600, fade .3 s); code draws plain 12 px caption text, warning-colored only at 5 and 1 minutes.
- Platforms: both; Free and Pro
- Fix idea: for one block say "10 minutes left." and draw the wide pill; needs a board for the CSE wording.

### Session (both): the clock tag always reads "5 min left", even in the last minute
- Severity: minor
- Evidence: pages/mock_session_page.dart:313-330 (`PantasTimer` called with no `warningLabel`); core/ui/components/pantas_timer.dart:27-31,100-110 (default `warningLabel = '5 min left'`, tag shown for every warning state); design/system/components/Timer/README.md ("a visible Tag says '5 min left'"); boards mobile/MK_FiveMin, MK_LastMinute (no tag; color only).
- Gap: at 00:58 the tag still says "5 min left" and, on the wide header, sits beside the proctor caption "1 minute left in this subject." On phone the tag adds about 28 px to the header and makes the header taller exactly when the proctor toast also appears. The boards draw no tag.
- Platforms: both; Free and Pro
- Fix idea: drop the tag on phone (boards) or make its label follow the time; README and boards disagree, so Aedwon rules.

### Session (both): last-minute clock color
- Severity: minor
- Evidence: pages/mock_session_page.dart:314 (`urgencyFor(...) != ample` gives one warning state; the last minute stays amber); board mobile/MK_LastMinute (time and bar `#D70015`, red); HANDOFF.md "Red is only for destructive actions or wrong answers"; Timer README "Don't use red for low time".
- Gap: board MK_LastMinute turns the clock red; the system rule and the code keep amber. Board and rule conflict; HANDOFF says "the newest boards win", but it also bans red for neutral states.
- Platforms: both; Free and Pro
- Fix idea: Aedwon rules; no code change until then.

### Session (wide web): question list header has the icon on the wrong side and larger than the board
- Severity: minor
- Evidence: pages/mock_session_page.dart:384-393 (`Row(Expanded(Text('Questions')), PantasIconButton md ...)`, md = 40, core/ui/components/pantas_icon_button.dart:20); boards web/MK_NavMotion, MK_SheetCSE, MK_SubmitCSE: `display:flex; align-items:center; gap:6px; margin:-8px 0 -4px -10px` containing a 36x36 button (radius 9, 20 px glyph) then "Questions" 17/600. HANDOFF: "an icon beside 'Questions'".
- Gap: board puts the 36 px hide icon first (left, 10 px outside the padding) and the title after it; code puts the title left and a 40 px icon at the far right. The panel-tab motion (300 ms wait, 500 ms arrive, 460 ms panel and bar inset, content fade .22 s after .12 s) matches MK_NavMotion.
- Platforms: wide web; Free and Pro
- Fix idea: swap the order, 36 px, margin -8/-4/-10.

### Session (phone): questions sheet draws a Close button the board does not have, and a help line the one-block board omits
- Severity: major
- Evidence: core/ui/components/pantas_sheet.dart:404-430 (`_CloseAction`: tertiary `PantasButton`, no `height` so 52, full width, padding top 8, bottom `max(34, safe area + 20)`); core/ui/components/new_design/question_grid_sheet.dart:200 (`closeLabel: 'Close'`); pages/mock_session_page.dart:176 (`helpText: 'Tap any question in this part to go to it.'`); boards mobile/MK_Sheet.dc.html and MK_SheetCSE.dc.html (zero "Close" strings; sheet ends at the help line on MK_Sheet and at "Submit the Exam" on MK_SheetCSE; MK_SheetCSE has no help line); design/system/components/Sheet/README.md:17,93,103 (requires Cancel or Close, example `btn--tertiary btn--phone`); README Button line 15 ("`btn--text-phone` is a 44px text button").
- Gap: this is Aedwon's finding 3 on the mock surface. A full-width borderless "Close" 52 high with 8 above and 34 below takes about 94 px; the board draws none. On a one-block CSE paper the help line "Tap any question in this part to go to it." names a part that does not exist and is not on MK_SheetCSE. "Submit the Exam" is the footer (52) above the Close.
- Platforms: phone; Free and Pro
- Fix idea: Aedwon rules between no button (boards, Esc/scrim/drag still close) and the README's 44 px `btn--text-phone`; drop the help line for one block.

### Session (phone): header height and side padding
- Severity: minor
- Evidence: pages/mock_session_page.dart:102-112 (minHeight `focusHeadPhone` 44; padding L4 T4 R8 B4; Row of 44 box, centered clock, 44 Pause); board mobile/MK_Paper and MK_Proctor header `padding:6px 8px 4px 8px; height:50px; grid 44px 1fr 44px`.
- Gap: header 44 min vs 50 (but it grows with the clock, bar and tag); left inset 4 vs 8, so the clock is centered 2 px left of the screen center. Strict mode keeps a blank 44 box where Pause was (correct per MK_LastQStrict).
- Platforms: phone; both
- Fix idea: 50 high, 8/8 sides.

### Session (wide web): "Saved on this device" hint in the bottom bar is false on web and resizes the bar
- Severity: major
- Evidence: pages/mock_session_page.dart:1091-1101 (`hint: _isAnswered(...) ? 'Saved on this device' : null`, `compact: true`); core/ui/web/web_components.dart:1556-1565,1696 (a hint makes the compact bar expand its middle); data/server_mock_view_cache.dart:7-9 ("convenience only: the paper, clock and answers are the server's"); design/system/components/FloatingBar/README.md:23 and design/system/patterns.md:115,122; no board draws it (grep of every MK_*, web and mobile).
- Gap: on web the answers are sent to the server and are not kept on the device (the cache keeps only the cursor and flags). The line tells the student the opposite of the truth (patterns.md:122 says never claim Saved before the server confirms). It also makes the compact bar jump in width each time the student lands on an answered or unanswered question. Boards MK_NavHidden, MK_SubmitCSE show the bar with only `←  N of M  →`.
- Platforms: wide web (server mock) only; Free and Pro
- Fix idea: remove the hint or tie it to the server's acknowledgement; needs a board if kept.

### Session (web): save-failure line floats over the paper with no surface
- Severity: minor
- Evidence: pages/server_mock_route.dart:475-487 (`Positioned(left:16,right:16,bottom:100)` Material transparent + `saveFailureLine`); core/error/state_patterns.dart:35-63 ("Could not save your progress." plus a 44 high tertiary "Try Again", `fullWidth:false`); native equivalent mock_start_route.dart:688 (toast "Could not save your mock progress.").
- Gap: no board draws a save failure in a mock. The line has no background, so it prints on top of the answer rows near the bar (same family as Aedwon's finding 5: a message drawn over the bottom bar zone instead of the bar changing). When the failed call is the final submit after the clock hits 0, the student stays on the paper at 0:00 with the same generic text and no "time is up" state.
- Platforms: web (server mock); native uses a toast; Free and Pro
- Fix idea: needs a board for the failed-save and failed-submit states; put the message in the bar.

### Session (both): scope notes with no gap found
- Severity: minor (informational)
- Evidence: pages/mock_session_page.dart (flag at top right of the question with F hint, 36 high, tertiary xs, padding L10 R8 gap 8: matches board `btn3` 36, 0 8 0 10, gap 8); `_PaperSwap` slide .38 s / crossfade .2 s on phone and wide (both animate); panel motion above; `LetterShortcuts` f, p, A to E, arrows on wide; end-early and submit dialogs match board text ("End Part N now?", "Submit the exam?", "You have 1 hr 12 min left and 4 questions blank. Once you submit, your answers can't be changed.", "Keep Working").
- Gap: none for those items. One-block submit uses the same dialog on both platforms. Submit button in the panel and the sheet footer say "Submit the Exam" (board).
- Platforms: both
- Fix idea: none.

### Pause (wide web): entry runs 3.9 s; the board's last keyframe ends near 3.4 s, so blink and tip start late
- Severity: minor
- Evidence: pause_page.dart:119-125 (`entry` 3900 ms wide, 2900 ms phone; exit 2400 wide, 2600 phone), 102-108 (blink starts 500 ms and tip loop 3 s after entry completes); board web/MK_PauseMotion.dc.html (`lcdrop 3.3s`, `pw .5s 1.55s`, `pin .55s` delays 2.7, 2.8, 2.92 s, `blink 1.8s .5s infinite`, `tip 6s linear 3s infinite`).
- Gap: board blink starts at 0.5 s and the first tip at about 5.4 s (3 s + 40% of 6 s); code blinks from about 4.4 s and first tips at about 9.3 s (3.9 + 3 + 2.4). The three content fades are one fade at 2.8 to 3.35 s in code (board staggers at 2.7, 2.8, 2.92 s). Phone follows MK_PauseFlow; its wobble starts when the 2.9 s entry ends, first tip at about 5.3 s. Wide animates wherever phone does (hourglass, drop, drain, glide, paper blur, resume reversal).
- Platforms: wide web; Free and Pro
- Fix idea: start blink and tip on the board's clock, not after the entry completes.

### Pause (both): dialog and page text match the boards
- Severity: minor (informational)
- Evidence: mock_session_page.dart:231-241 ("Real exams don't pause.", "Use this only when you really have to. The clock stops, but you won't get this during the real exam.", "Don't show this again", "Keep Going", "Pause"); pause_page.dart:176-182 ("Discard this mock?", "Your N answers get deleted, and this attempt won't appear in your record. It also doesn't use up a mock attempt.", "Keep It", "Discard"). Boards MK_PauseWarn, MK_Discard, web/MK_Paused: same text.
- Gap: one addition: with 0 answers the code prints "Nothing is answered yet. This attempt won't appear in your record, and it doesn't use up a mock attempt." No board covers n = 0 (decision not found). A one-block pause shows "left" instead of "left in this part" (matches web board MK_Paused only for parts; no CSE pause board).
- Platforms: both
- Fix idea: needs a board only if Aedwon wants the n = 0 wording reviewed.

### Review (phone): the note card differs from MK_ReviewQNote and MK_ReviewBlank
- Severity: major
- Evidence: pages/mock_review_page.dart:1306-1396 (labels "I misread", "I forgot", "I didn't know", "I ran out of time", "I skipped it to come back later", "Type my own"; each tap saves at once; "Save Note" appears only after Type my own); wide 1400-1414 and 1553-1572 ("Not Now", "Add Note"); boards mobile/MK_ReviewQNote, MK_ReviewBlank, QN_Wrong ("I misread it", "I knew it, I just slipped", "I didn't know it", "Type my own", then "Cancel" and "Add Note"); web/MK_ReviewQ and QN_Wrong ("I misread", "I forgot", "I didn't know", "Not Now", "Add Note").
- Gap: phone code uses the web board's wording and has no Cancel and Add Note pair; the phone board has both. Taps save instantly, so a wrong tap cannot be cancelled. (The same card lives in Quiz; this is the mock-review copy.)
- Platforms: phone; Pro only for notes (board MK_ReviewQFree has no note icon)
- Fix idea: follow the phone board text and the Cancel/Add Note pair.

### Review (wide web): the flag offer wording differs from the board
- Severity: minor
- Evidence: pages/mock_review_page.dart:545-548 ("You flagged N questions while the clock was running. Do you want to save them?"); board web/MK_ReviewFlagged ("You flagged 12 questions during the mock. Save them?"); phone board and code both say "while the clock was running. Do you want to save them?".
- Gap: wide copy follows the phone board, not the wide board.
- Platforms: wide web; both
- Fix idea: use the web board's sentence on wide (copy only; rule 4 lets the lead settle it).

### Results (both): everything matches the boards except naming; Free/Pro lines checked
- Severity: minor (informational)
- Evidence: pages/mock_results_page.dart:83-85 (caption "N of M correct answers" for CSE, "N correct, minus X wrong" only for UPCAT), 186-202 and 466-483 (strict forfeit text), 668-729 (Free line "On Free, you can go through these until your next mock opens on <date>.", locked card "Go through all N questions again with Pro." with "See Pro"), 536-546 (wide "Open until your next mock on <date>"); boards MK_ResultsFree, MK_PastFreeLocked, MK_PastFreeOpen, web/MK_ResultsFree.
- Gap: text matches. "Results not available" fallback (mock_results_route.dart:140-156) is bare `Text` plus a 52 high tertiary Back, no board (L_ or QZ error pattern would apply). Wide "Done" sits top right beside the title (HANDOFF) and Enter hint; phone has an X and a bottom Done (board).
- Platforms: both
- Fix idea: use `StateView` for the empty result; needs no board.

### Results (both): finale only plays for a fresh, completed, count-matching result; timings
- Severity: minor
- Evidence: pages/mock_results_route.dart:206-232 (plays only if `fresh`, not `fromRecord`, not strict-exit, completed, CSE exam id, and the finale's question counts equal the scored totals); widgets/cse_mock_finale.dart:36-70 (phone 9650 ms controller with board-sampled tracks; wide hands off to `WebMockFinale`, 11350 ms, web_mock_finale.dart:30-34); HANDOFF MK_Finale 11.35 s; board mobile/MK_Finale loops at 11350 ms.
- Gap: wide runs the 11.35 s board clock; phone runs a 9.65 s controller over sampled tracks (the last tracks, past-results line at 9.3 s, end before 9.65 s, so the phone board's remaining 1.7 s is a loop hold; not verified frame by frame). On a count mismatch (for example a retired question) the finale is skipped silently and results show at once. Strict-exit skips the finale (board MK_Forfeit shows results directly).
- Platforms: both
- Fix idea: confirm the phone hold; no change needed otherwise.

### Setup/skeleton (phone): loading state shows a text the page does not have
- Severity: minor
- Evidence: widgets/mock_skeletons.dart:38-41 (`AppBar(title: Text('Mock exam'))`, content padding 20/18/20/32); pages/mock_setup_page.dart:76-121 (no app bar, "Quiz" link, padding 16/8/16).
- Gap: the setup skeleton prints "Mock exam" in a Material app bar and uses 20 px sides; the loaded page has the "Quiz" link and 16 px sides. The title swaps and the table jumps 4 px sideways on load. L_Rules says skeletons show only after 300 ms; not checked in code.
- Platforms: phone; both
- Fix idea: draw the skeleton from the loaded page's geometry.

### Setup/Quiz card (both): Free interval is 14 days on phone and 30 days on web; boards still say 14
- Severity: major
- Evidence: widgets/mock_card.dart:23 (`freeMockIntervalDaysWeb = 30`), app/routes/quiz_routes.dart:183,203 (native 14, `submittedAt + 14 days`); pages/mock_setup_route.dart:198-202 (not-open view says 30 days); boards mobile and web QZ_Free, QZ_First ("Free includes one mock every 14 days"); docs/superpowers/decisions/2026-10-19-pwa-launch-log.md:520-531 (Aedwon: "okay go with your recommendation on the mock 30 days"; one per rolling 30 days).
- Gap: the same Free rule reads and acts differently by platform, and the boards (web and mobile) were never updated to 30. The native app (phone) still allows a Free mock every 14 days.
- Platforms: both; Free only
- Fix idea: confirm whether native stays at 14; update the QZ boards. Quiz tab card is outside this slice; recorded because it gates the mock.

### Session (web): leaving the tab pauses a non-strict mock without the warning
- Severity: minor
- Evidence: pages/server_mock_route.dart:406-422 (`hidden`/`paused` lifecycle calls `session.pause()` when not strict); pages/mock_session_page.dart:218-253 (the pause warning dialog is skipped); boards MK_PauseWarn (warning precedes pause), no board for auto-pause.
- Gap: a student who switches tab, for example to a calculator, returns to the Paused hourglass page. Strict mode instead gives a 10 s grace (`StrictModeLifecycle.guardDelay`) then forfeits; the Setup text says "Leaving the app instantly ends and submits your answers", which is not instant (10 s).
- Platforms: web mostly (native app background does the same); Free and Pro
- Fix idea: needs a ruling and board text; change "instantly" or the 10 s.

### Dead code in the mock folder
- Severity: minor
- Evidence: widgets/mock_resume_sheet.dart, widgets/exam_marks_offer.dart, widgets/mock_status_card.dart, widgets/score_headline.dart (no references anywhere in lib/; grep). `ScoreHeadline` holds "Passing", "Close to passing", "Not passing"; `MockStatusCard` holds "Mock ready", "Next mock in N days".
- Gap: the resume sheet, the marks offer and the status card in the brief are not live screens; resume runs through the Quiz card and `/quiz/mock/resume/:id`. If `ScoreHeadline` were wired up, the band words would print, so the guard is only that `scoreBands` is null for every CSE blueprint (content/mock/*.yaml has no scoreBands).
- Platforms: n/a
- Fix idea: delete, or add a test that CSE never gets a band.


## Button inventory (finding 3)

Heights from the component specs (`PantasButton` default phone height 52 when `height` is not given, `fullWidth` default true; `WebButton` standard 44, xs 36; `WebBackLink` 40; `PantasIconButton` 44 / md 40). "Hit area" is the tappable box. Board value is from the named board; "not checked" means no board element was found for it.

| Widget | File:line | Height | Padding | Hit area | Board value |
|---|---|---|---|---|---|
| Questions sheet "Close" (phone mock) | core/ui/components/pantas_sheet.dart:404-430, used by question_grid_sheet.dart:200 | 52 (no `height` given) | T8, B max(34, inset+20), sides 20 | full sheet width x 52 (strip about 94) | none: MK_Sheet and MK_SheetCSE have no Close. README example `btn--phone` 52; `btn--text-phone` 44. FLAG: larger than board (board shows nothing) |
| "Results not available" Back | pages/mock_results_route.dart:144-156 | 52, `fullWidth:false` | button default | text width x 52 | none (no board). FLAG |
| Resume sheet "Discard" (dead code) | widgets/mock_resume_sheet.dart:42-46 | 52, full width | 24 around the sheet | full width x 52 | none; dead |
| "No thanks" in marks offer (dead code) | widgets/exam_marks_offer.dart:53-58 | 52 | half width | half x 52 | none; dead |
| Phone pause "Discard This Mock" | pause_page.dart:621-627 | 44 (`PantasSize.btn`) | bottom bar 16/14/16/32 | full width x 44 | MK_PauseA: 44 high, centered, gap 8 under Resume; bar padding 14/16/30 (code bottom 32). OK |
| Wide pause "Discard This Mock" | pause_page.dart:447-452 | 44 (`WebButton` tertiary, red) | 20 sides | label + 40 x 44 | web/MK_Paused: not measured. Not flagged |
| Wide pause button | mock_session_page.dart:927-932 | 44 tertiary | 20 sides | label + icon + 40 x 44 | board `btn3` height 44 (MK_Proctor). OK |
| Flag (phone and wide) | mock_session_page.dart:335-358 | 36 (xs tertiary) | L10 R8, gap 8 | label + icon + key hint x 36 | `height:36; padding:0 8px 0 10px; gap:8` (MK_Proctor). OK |
| "Quiz" back link, phone setup | mock_setup_page.dart:85-111 | min 44 | L4 T6 R8 around; icon 24, gap 2 | icon + text x 44 | `padding:6px 8px 0 4px; height:44px`, gap 2. OK |
| "Quiz" back link, wide setup | mock_setup_page.dart:408-413 | 40 (`PantasSize.back`) | L0 (nudge off), shifted -6 | label + chevron x 40 | `.back` 20 px chevron + 17 px label. Not measured; likely OK |
| "Your record" back link, results | mock_results_page.dart:116-121, 312-317 | 40 | phone L8 | label x 40 | board MK_PastPro: not measured |
| "Results" / "All questions" back links, review | mock_review_page.dart:140-196 | 40, in a 46 app bar with 8 top | link only | label x 40 | MK_ReviewAll: link sits "5 px lower"; not measured |
| Flag in review top bar, wide | mock_review_page.dart:153-164 | 44 tertiary | 20 sides | label + hint x 44 | web/MK_ReviewQ: not measured |
| "No Thanks" flag offer, wide | mock_review_page.dart:553-557 | 44 tertiary | 20 sides | label x 44 | web/MK_ReviewFlagged: row with two buttons; not measured |
| "Not Now" note card, wide | mock_review_page.dart:1557-1561 | 44 tertiary | 20 sides | label x 44 | web/MK_ReviewBlank "Not Now"; not measured |
| Phone note card "Save Note" (filled) | mock_review_page.dart:1382-1393 | 52 primary | card 16 | full width | board has Cancel and Add Note instead. Not borderless; listed because it replaces the board pair |
| "Try Again" in save failure | core/error/state_patterns.dart:52-59 via server_mock_route.dart:478-485 | 44, `fullWidth:false` | default | text x 44 | none. FLAG (floats over the paper) |
| "Discard saved mock" (native error) | pages/mock_start_route.dart:848-856 | 44 tertiary critical | default | text x 44 | none |
| Dialog "Keep Going" / "Keep Working" / "Keep It", wide | core/ui/components/centered_dialog.dart:150-157 | 44 (WebButton tertiary) | 20 sides | label x 44 | web/MK_Discard, MK_EndEarly: pair; not measured |
| Dialog buttons, phone | centered_dialog.dart:182-190 | 46 filled neutral/primary | equal halves | half x 46 | MK_PauseWarn/MK_Discard pair; filled, not borderless |
| Panel tab "Show the question list" | widgets/web_mock_panel_tab.dart:96-110 | 46 | width 32, 40 on hover | 32 to 40 x 46 | MK_NavMotion: `.tab` widens on hover; matches |
| Panel hide icon | mock_session_page.dart:387-392 | 40 (`md`) | row 24 | 40 x 40 | board 36 x 36, radius 9, margin -8/-4/-10. FLAG (4 px larger, other side) |
| Question count button (phone bar) | core/ui/components/question_count.dart:60-80 | min 44 | L16 R12 + 16 caret, gap 8 | text + caret x 44 | MK_Paper count in the bar; not measured |
| Quiz-card "Change the setup" (custom only) | widgets/mock_card.dart:310-315 | 44 tertiary | default | full width x 44 | not checked (custom exam only) |
| Quiz-card "Take the Exam" etc. (secondary, filled) | widgets/mock_card.dart:129-136 | 48 | default | full width x 48 | QZ boards are outside this slice |

Free vs Pro: none of these differ between Free and Pro. The review links differ: Free shows "Open until <date>" or the locked card with "See Pro" (44 high, wide) or 52 (phone, `PantasButtonVariant.secondary`, mock_results_page.dart:717-721).

## Figures (P10)

Source key: measured (counted from the pinned paper or the clock), published (by the Civil Service Commission, as the repo records it), named algorithm, reported (one person, or press/PIA relays, per content/mock/*.yaml), invented (a product number with no outside source). I did not call any hosted service; "published" is what the repo's own yaml and decisions say, not re-verified outside.

### Setup screen (pages/mock_setup_page.dart; blueprint from content/mock/cse-pro.yaml and cse-sub.yaml)

| Figure | On-screen text (exact) | Source | Reads as official? |
|---|---|---|---|
| cse-pro total | "155 total items · 3 hr 10 min" (line 146 phone, 427 wide) | 155 = sum of one examinee's recollection (20+55+35+45), relayed by Aedwon 19 Oct 2026; yaml `source: reported`. The Civil Service Commission publishes no per-area counts (yaml). `blueprint.totalPublishedItems` is deliberately absent | Yes. No "reported" or "approximate" qualifier on screen. No "Pantas practice exam" label either (`mockPracticeLabelFor` only fires if the blueprint name carries it; it does not) |
| cse-pro 3 hr 10 min | same line (190 minutes) | Reported: PIA and CSC-relaying outlets (yaml) | Yes, stated flat |
| cse-pro section rows | "General Information 20", "Verbal Ability 55", "Analytical Ability 35", "Numerical Ability 45" (table, `Items` column) | Reported (one examinee) | Yes. Board MK_SetupCSE draws 45/45/40/40 and 170 and says "counts are placeholders until sourced"; the code differs from the board |
| cse-pro personal-information line | "The real exam also has 15 personal-information items. They are not scored, so this mock leaves them out." (lines 180-182, 320) | `unscoredItems: 15`, same examinee. NOTE the cse-sub yaml cites a 2020 Commission advisory as "150 test items plus 20 descriptive questionnaire items for the Professional level"; that conflicts with 155 and 15 for the same level (both sum to 170). Not resolved in the repo | Yes; states a fact about "the real exam" |
| cse-sub total | "145 total items · 2 hr 40 min" | 145: "2020 CSC advisory (145 plus 20 for the Subprofessional level); whether that still holds is unconfirmed" (yaml). 160 minutes: PIA/CSC-relaying outlets | Yes. Nothing on screen says "unconfirmed" |
| cse-sub section rows | "Verbal Ability 36", "Numerical Ability 36", "Clerical Ability 36", "General Information 37" | INVENTED even split: "an even division chosen here until a taker of this level supplies the real counts" (yaml). Ruled DO LATER (decisions/2026-11-17-fable-backlog-rulings.md A17) | Yes. It reads as the real composition. This is the main P10 risk on the setup screen |
| cse-sub personal-information line | "The real exam also has 20 personal-information items. They are not scored, so this mock leaves them out." | 2020 advisory per yaml (20), unconfirmed | Yes |
| Short-bank notice | "This mock has N questions instead of 155." (lines 198, 329) | Measured (count of questions the bank can fill) | Honest |
| Paper rule | "This paper runs as one block. You can move around the whole paper and submit when you're done." | Reported format (one booklet, one clock; yaml `sectionalTiming: roamable`) | Yes |
| Strict mode | "Closest to the real exam. Turn it on when you can take the whole mock without interruptions." and (on) "No pausing and no ending a section early. Leaving the app instantly ends and submits your answers, finished or not finished." | Product rule. The real grace is 10 s (`StrictModeLifecycle.guardDelay`), not "instantly": invented 10 s, not shown | "Closest to the real exam" is a claim about the real exam |
| Clock | "The clock starts when you tap." / "when you click." | Behavior | n/a |

### Run (pages/mock_session_page.dart, proctor_toast.dart, part_clock.dart)

| Figure | On-screen text | Source | Official? |
|---|---|---|---|
| Clock | e.g. "3:10:00", counts down from the blueprint's 190 or 160 minutes | Reported minutes (above); the countdown is measured | Reads as the real time limit |
| Proctor calls | "10 minutes left in this subject.", "5 minutes left in this subject.", "1 minute left in this subject." | Board-set thresholds 10, 5, 1 (`callThresholdsMinutes`); invented product behavior, not a Commission rule | Reads as a proctor call |
| Clock tag | "5 min left" under 5 minutes (also shown in the last minute) | Board/README threshold of 5 | Reads as a warning |
| Counter | "N of 155" (cse-pro), "N of 145" (cse-sub) | Measured from the pinned paper | Follows the total above |
| Question list | "WHOLE PAPER", "N of 155 answered" | Measured | n/a |
| End/submit dialog | "You have 1 hr 12 min left and 4 questions blank. Once you submit, your answers can't be changed." | Measured | n/a |
| Pause | "Real exams don't pause." | Claim about the real exam; product stance | Yes |

### Results and review (pages/mock_results_page.dart; domain/use_cases/compute_results.dart; domain/mock_results.dart)

| Figure | On-screen text | Source | Official? |
|---|---|---|---|
| Score ring | "NN.N%" one decimal (`decimalPlaces`), caption "N of M correct answers" | Named algorithm: raw correct / total x 100 (`mockScorePercent`). Only `exam_upcat` deducts one quarter per wrong answer, so CSE has no deduction rule on screen | Honest. The percent is a practice score |
| Pass mark / bands | NOT PRINTED for CSE. `compute_results.dart:99-110` returns `null` when `scoreBands` is null; no cse yaml has `scoreBands`; `ScoreHeadline` ("Passing", "Close to passing", "Not passing") is unreferenced (dead code) | The Commission's published passing rate (80%, from public knowledge, not verified here) is not shown anywhere | Compliant with "never print an unpublished threshold" |
| Hidden thresholds that color things | Accuracy bars use `accuracyTint` clamped 40% to 80% (theme_names.dart:86) and chart steps "65 to 74%", "75% and up" (pantas_colors.dart) | Invented color ramp; the number is always printed with it; no word says pass or fail | Not a printed pass mark, but a student may read the teal top step as "good enough" |
| Per-section rows | "58 / 80" and "72%" per section (`ScoreBreakdownRow`), `Verbal Ability`, etc. | Measured | n/a |
| Past results | "Your last N mocks ranged from X% to Y%. The latest is Z%." (`mockPastSummary`), "One result so far." | Measured | n/a |
| Free review window | "On Free, you can go through these until your next mock opens on <date>." (phone), "Open until your next mock on <date>" (wide), "Open until <date>" (from record) | Product rule: Free review stays open until the next Free mock opens; 30 days on web, 14 days on native (see finding above) | n/a |
| Quiz card | "Free includes one mock every 30 days." (web), "every 14 days" (native); "You're on Pro. Take as many mocks as you like." | Product decision (Aedwon, 19 Oct 2026, 30 days on web); boards say 14 | n/a |
| Not finished | "With strict mode enabled, you left the app during Part N, so the mock ended there. Everything you answered before then is scored." | Behavior; for a one-block CSE paper there is no "Part N" (`forfeitedPart` is the native part index + 1, so it would read "Part 1"; the web server path passes no part, so the line is omitted) | Wording not designed for one block. Needs a board |

Notes on the CSE specifics the brief called out:
- "145" and "165": "145 total items" prints on the cse-sub setup screen and is the only published-sourced total. "165" (145 + 20) never prints. "170" and "155" for cse-pro: 170 prints nowhere (board shows it; code shows 155). "160 minutes" prints as "2 hr 40 min". Nothing on the setup screens says these are practice figures or unconfirmed, so all of them read as official.
- The even-split 36/36/36/37 prints as table rows with no marker, even though the yaml and ruling A17 call it a placeholder.
- Fix idea for P10: add one line under the table when `source` is `reported` or a section is a placeholder, for example "Item counts are estimates." The wording is Aedwon's call under rule 4 only if layout is already approved; the board MK_SetupCSE carried the "placeholders until sourced" note in its title only.

