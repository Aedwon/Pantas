# Feedback (Beta) client screens: implementation plan

Date: November 7, 2026. Lead: Claude (Opus 5.5). Policy: origin/main 4b8ea2833.
Spec: `docs/superpowers/specs/2026-11-07-beta-feedback-page.md` (this branch). Server plan, lane C:
`docs/superpowers/plans/2026-11-07-beta-feedback-page.md`. Decisions: launch log, Nov 7 entries
("Feedback page decisions", "Feedback (Beta) decisions and the early list").
Branch `web/beta-feedback-ui-r1` = `web/beta-feedback-r1` 1c1f42942 + `web/visual-check-fixes-r1`
571eea1aa (merge c791c5bdf). No deploy from this branch; the lead integrates with `web/load-speed-r1`.

Boards (approved, match 1:1): review canvas https://claude.ai/artifact/EBQopPTcLczwabNWkTSake, page
"Feedback (Beta)": FbSettingsB, FbPage, FbPageDark, FbSurvey, FbReward, FbDesk, FbDeskDark,
FbDeskSurvey, FbDeskReward (version 1794038149-e975). Read-only copies outside the repo for workers:
`~/Library/Application Support/Claude/side-session-notes/local_5ba77a0f-204d-46ca-9a4e-0d4251343d72/beta-feedback-boards/`.
**Exception:** the device line ("Your device and browser are sent with it: ...") is removed on every
board (Aedwon: "Don't show it"). The device and browser still go with each report as `userAgent`.

## Global constraints

- `AGENTS.md`, `WORKFLOW.md`, `SUBAGENTS.md` (origin/main) apply. No AI attribution anywhere.
- Test first per task. `flutter analyze` clean, `dart format` clean, layering check clean.
- Colors come from `context.colors` (phone) and `context.webTokens` (wide web); they already hold the
  board tokens (accent #0B7A68 / #4CC3AC, accentFill, accentTint, accentTintText, fill, separator,
  cardEdge, secondaryLabel, tertiaryLabel, chevron). Font is the app's Geist.
- Motion curves from `PantasCurves`, durations from the boards (below). Every animation is skipped
  when `MediaQuery.disableAnimationsOf(context)` is true (final state, no delay).
- Wide web animates wherever the phone animates (written rule 1).
- Navigation with `context.push`. Interface copy exactly as on the boards.
- Never invent a figure: only the tester's own day count and dates are shown.

## Shared interface (lead, committed first)

- `lib/features/beta_feedback/domain/beta_feedback_models.dart`: `BetaReward`, `SentFeedback`,
  `PickedImage` (+ `problemWith`), `SurveyAnswers`, `BetaRewardActivation`, `BetaDayKind`,
  `BetaFeedbackException`/`BetaFeedbackFailure`, `BetaFeedbackApi`, `BetaImageSource`.
- `lib/features/beta_feedback/application/beta_feedback_providers.dart`: `betaFeedbackApiProvider`,
  `betaImageSourceProvider` (both throw until lane D wires them), `betaFeedbackVisibleProvider`,
  `betaRewardProvider`, `sentFeedbackProvider`, `betaFeedbackClockProvider`.
- Lane D may add fields but may not rename or remove anything here without the lead.

## Lane D: data, day reporting, image sources (Sonnet, worktree)

Owns `lib/features/beta_feedback/data/**`, `lib/features/beta_feedback/application/**` (except the
shared file's existing declarations), `lib/core/platform/callable_options.dart`, `lib/app/app.dart`
(one watch line), `pubspec.yaml` (`image_picker` only), `test/features/beta_feedback/data/**`,
`test/features/beta_feedback/application/**`, `test/core/platform/callable_options_test.dart`.

- D1 `FirebaseBetaFeedbackApi implements BetaFeedbackApi`. Callables through `callFirebaseFunction`
  (region asia-southeast1). Add `sendBetaFeedback`, `recordBetaDay`, `submitBetaSurvey`,
  `activateBetaReward`, `getBetaReward` to `replayProtectedCallables` (they consume App Check
  tokens) and keep `functions/test/app-check.test.mjs` REPLAY_PROTECTED in step only if that test
  lists them (report, do not edit functions). Map `FirebaseFunctionsException.code`
  `failed-precondition` → notAllowed, `already-exists` → alreadyDone, else other. `send`: upload
  each image with `firebase_storage` `putData` (contentType metadata) to
  `betaFeedback/{uid}/{feedbackId}/{i}`, then call with `{feedbackId, text, attachments:[{path,
  contentType}], userAgent, appVersion, examId?}`. `userAgent` from the browser on web (truncate
  300), platform name elsewhere; `appVersion` from the existing build info source (truncate 40).
  `sent()`: Firestore `users/{uid}/betaFeedback` ordered by `createdAt` desc, snapshots.
  `imageUrl`: `getDownloadURL`. `feedbackId`: 20 random `[A-Za-z0-9]` chars (Random.secure).
  Wire `betaFeedbackApiProvider` to it. Tests with fakes for the callable, uploader and reader seams.
- D2 `BetaImageSource`: `image_picker` `pickMultiImage(limit: max)` mapped to `PickedImage`
  (content type from mime or extension). Web `dropsAndPastes()`: `package:web` document `paste`
  (clipboardData files/items of image types) and `dragover`/`drop` (preventDefault so the browser
  does not open the file) with a conditional import; other platforms an empty stream. Listeners
  are added on subscribe and removed on cancel. Wire `betaImageSourceProvider`.
- D3 Day reporter: `betaDayReporterProvider` (`Provider<void>`) watched from `App` beside
  `studyDeliveryLifecycleProvider`. Active only when `betaFeedbackVisibleProvider` and the local date
  is Nov 8 to Nov 16, 2026. It listens to today's plan for the active exam (`roadmapTodayProvider`,
  which is server-backed on web) and calls `recordDay(BetaDayKind.plan)` when `originalDone` is true
  on a non-rest day. On a rest day it calls `recordDay(BetaDayKind.restDay)` after a completed
  streak-eligible session today (`quizSessionPanelRevisionProvider` change plus a completed attempt
  today with `SessionOrigin.isStreakEligible`, as `record_provider.dart` reads it). Once per local
  date: remember the reported date in the app's existing local key-value store (find it; do not add
  a package) only after the call succeeds. Failures silent; the next app open or completion the same
  day retries. After success invalidate `betaRewardProvider`. No Home widget changes.
  Tests: plan done reports once; not done does not; rest day after an eligible session; ineligible
  origin does not; repeat on the same date does not; outside Nov 8 to 16 does not; non-tester does
  not; a failure is retried.
- Checks: focused tests, `flutter analyze`, format, layering, and `flutter build web` compiles
  (web) plus analyze for native imports.

## Lane U: screens (Sonnet, worktree)

Owns `lib/features/beta_feedback/presentation/**`, `lib/features/settings/presentation/
settings_home_page.dart`, `.../widgets/settings_pane_page.dart`, `.../widgets/beta_pro_row.dart`
(only if the row needs a flag), `lib/app/routes/settings_routes_native.dart`,
`lib/app/routes/settings_routes_web.dart`, `test/features/beta_feedback/presentation/**`,
`test/features/settings/**` (new or updated row tests). Tests override `betaFeedbackApiProvider`,
`betaImageSourceProvider`, `betaAccessProvider` and the clock with fakes.

Routes (both route lists): `/settings/beta-feedback`, `/settings/beta-feedback/survey`,
`/settings/beta-feedback/sent/:id`. Wide-web section name `Feedback`; nested pages use
`backLabel: 'Feedback'` (gives the Esc hint and back link from `SettingsPanePage`).

### U1 Settings row (FbSettingsB phone, FbDesk list)

- Phone: a new first card after the account card (24 px gap): row Feedback, then the existing
  `BetaProRow` inside the same card, then `BetaProNote` under the card. The Pantas Pro card then holds
  only Pantas Pro. Non-testers: no Feedback row; Beta: Pro Features stays where it is today.
- Row: chat-bubble glyph (24 px, stroke 1.8, accent; paths `M4 5.5h16v11H9l-5 4z`,
  `M8.5 10h7M8.5 13h4`) in the 30 px box, title "Feedback" 17 px with the raised BETA mark
  (9 px, w700, letter spacing .08 em, line height 1, accent, 1 px down, 4 px after), value
  "{n} of 5 days" (17 px secondary), chevron. Same paddings as the other rows (14/16, min 45).
- Wide web list: same card order; `WebRow` style, glyph 22 px, title 16 px with BETA mark, value
  15 px (accent when selected, secondary otherwise), selected tint when the Feedback page is open,
  no chevron. Divider at 50 px before Beta: Pro Features.
- Value while loading: empty, then fades in (quick, ease). Count over 5: "{n} of 5 days" is kept to
  at most "5 of 5 days" (lead ruling, see Undrawn states).

### U2 Feedback page (FbPage, FbPageDark, FbDesk, FbDeskDark)

Phone (`SettingsPanePage` phone path, back "Settings", compact 28 px title with BETA mark at
4 px down / 4 px after, title padding 6/22, page padding 0 16 40):

1. Days card (radius 14, dark 1 px edge): "{n} of 5 days" 24 px w700 (−0.288), subline "A day
   counts when you finish your whole Today plan." 15/1.4 secondary, padding 18 16 16 gap 4. Strip:
   padding 4 12 18, 7 equal columns gap 4; label 11 px w500 secondary (Mon..Sun), 36 px circle gap 6.
   Counted: accentFill circle, white check (18 px, stroke 2.6, `M5 12.5l4.5 4.5L19 7.5`), semantics
   "Nov 9, counted". Today not counted: label "Today" w600 accent, 1.5 px accent ring, number 15 w600
   accent. Today counted: label "Today" accent, counted circle. Other days: fill circle, number 15
   secondary. Separator inset 16, then row "Exit Survey" / value (min 45, 17 px).
2. Footnote "Count 5 days from Nov 9 to 15 and send the exit survey to earn 1 year of Pro." 13/1.4
   secondary, padding 7 16 0.
3. 24 gap, header "SEND FEEDBACK" 13 w600 letter .26 secondary, padding 0 16 7. Compose card
   (radius 14, padding 14, gap 14): text field 5 lines min, 17/1.35, no border, placeholder "What
   worked, what broke, what you would change", label "Your feedback" for semantics. Thumbnails 72 px
   radius 10 gap 10, image cover, remove button 22 px circle rgba(0,0,0,.55) with 12 px X at 4/4,
   label "Remove image {i}". Add tile (only while fewer than 3): 72 px radius 10 accentTint,
   accentTintText plus (22 px, stroke 2) over "{k} of 3" 11 w500, label "Add image". With no images
   the row shows only the add tile reading "0 of 3".
4. 14 gap, button "Send Feedback" 52 px radius 14 accentFill white 17 w600, full width. Disabled
   (no text and no image): disabledBackground / tertiary label colors from the survey board.
5. 24 gap, header "SENT", list card: row padding 12 16, text 15/1.35 two lines max, meta
   "Nov 11, 9:41 PM · 1 image" (or "· 2 images"; no images: date only) 13 secondary, gap 3, chevron;
   separators inset 16. Hidden when nothing has been sent.

Wide web (`SettingsPanePage` wide path, section "Feedback"): heading glyph 22 px accent then h2
26 px w700 "Feedback" with BETA (4 px down). Days card radius 16, padding 18 16 6, count 22 px,
strip padding 14 16 18 with 7 fixed 40 px columns spaced between, labels 12 px "Mon 9".."Sun 15",
circles 40 px, check 20 px. Survey row 16 px padding 12 16. Footnote padding 8 16 0. Compose card
radius 16 padding 14 16 16, text 4 lines 16/1.4, thumbs 64 px with 20 px remove (11 px X), add
tile 64, then "or drop or paste screenshots here" 13 secondary 6 px after the tiles. Under the card
(14 px): "Send Feedback" 44 px radius 12 padding 0 20, 16 w600, with key chip "⌘ Enter" (Ctrl Enter
off Apple; 20 px, radius 5, white 18% background, 11 w600). Cmd/Ctrl+Enter sends. Drops and
pastes add images while the page is shown. Sent rows one line, ellipsis, 16 px, meta right
"1 image · Nov 11" 15 secondary, chevron; separators inset 16 both sides; header padding 0 16 8.

Motion (canvas note fbn5): counted days pop in on first build of the strip: scale .4 → 1.08 → 1
and opacity 0 → 1, 450 ms, `popC` per keyframe segment (0–60 %, 60–100 %), delays 100, 180, 260 ms
... (+80 ms each counted day, in order). The count digit rolls up (old value slides up and fades
out, new slides in from below, 240 ms shared) when the count is higher than the last count this
device showed (remember it locally). Picked thumbnails rise in: translateY 10 → 0, opacity 0 → 1,
300 ms `riseIn`, 80 ms stagger. Send Feedback: while sending, a white spinner (18 px, 2.4 px ring,
the survey board's) replaces the label; on success a check draws in the button (`checkDraw`, 350 ms)
and holds 600 ms, then the label returns, the form clears, and the new item slides into the top of
Sent (size from 0 with fade and 8 px rise, 300 ms `riseIn`). On failure the draft stays and the
app's existing toast says "Could not send. Try again." Removing a thumbnail fades and shrinks it
(160 ms ease).

### U3 Exit survey (FbSurvey phone, FbDeskSurvey wide)

Opened from the Exit Survey row while the survey is open and not sent. Back "Feedback".
Phone: title "Exit Survey" 28 w700, subline "7 questions. You can send it once, until Nov 22."
15 secondary (padding 0 4 22). Card row "Your Sent Feedback" / count / chevron; footnote "Look back
at what you sent while you answer." Tapping expands the list inline exactly as the wide board
(grid rows 0 → 1, 300 ms shared; chevron rotates 90°, 240 ms shared; items fade .2 s and rise 6 px
with 60/100/140 ms delays; each item: date column 52 px secondary, text, "1 image" secondary).
Question titles 17 w600 (phone) / 16 w600 (wide), 28 px (phone) / 30 px (wide) apart.
- Q1 "How often did you use Pantas this week?": phone a column gap 8, wide a 2 by 2 grid. Options
  Every day / Most days / A few days / Once with letter circles A–D (30 px phone, 28 px wide).
  Picked: 1.5 px accent border, accentTint background (180 ms ease), filled letter pops (420 ms,
  scale .4 → 1.12 → 1, popC).
- Q2 "How easy was Pantas to use?" 1–5, ends "Hard" / "Easy". Q3 phone "How useful was Pantas for
  your exam prep?", wide "How useful was it for your exam?" 1–5, ends "Not useful" / "Very useful".
  Wide puts Q2 and Q3 side by side (gap 24). Segmented: 44 px, radius 10, fill, padding 6, gap 4;
  thumb radius 8, white (dark #4A4A4A) with 0 1 3 rgba(0,0,0,.1), slides 240 ms shared, fades in
  160 ms on the first pick; label 14 w600, picked label color, others secondary (160 ms ease).
- Q4 "Will you keep using Pantas after the beta?" Yes / Maybe / No, same segmented, phone full
  width, wide 320 px.
- Q5 "How likely are you to recommend Pantas to a friend?" 0–10 pills 40 px: phone 6 columns gap 8,
  wide 11 columns gap 6. Unpicked card (wide adds the dark edge); picked label color fill with card
  text w600, pops 360 ms. Ends "Not likely" / "Very likely".
- Q6 "What should we improve most?" text, required, phone 4 lines, wide 3. Q7 "Anything else you
  want to tell us?" plus "Optional" w400 secondary, phone 3 lines, wide 2. Phone: no border when
  empty, 1.5 px accent when it has text. Wide: 1 px separator, with text 1 px accent plus 1 px accent
  ring (160 ms). Placeholder "Your answer".
- Wide only: under the subline a 7-segment progress bar (4 px, gap 6, fill grows 240 ms shared)
  and "{n} of 7" (13 w500 secondary, tabular, 72 px right aligned). Counts each answered question,
  Q7 when it has text.
- Send Survey: phone 52 px full width radius 14; wide 44 px min 156 radius 12 with the note
  "Answer questions 1 to 6 to send." / "You can send it once." 13 secondary 14 px after it.
  Disabled until 1 to 6 are answered (disabledBackground, tertiary label). Sending: spinner.
  Then the appeal line "Think a day was missed? Email support@pantas.study by Nov 30."
- Sent state (both): centered, circle (76 px, r 35, stroke 3 accent) draws 500 ms `checkDraw`, check
  (stroke 3.6) draws 350 ms at 420 ms, three ripples at 700/820/940 ms (spread 0 → 22 px,
  rgba(11,122,104,.38) → 0, 700 ms easeOut), "Survey sent" 26 w700 rises (14 px, 450 ms riseIn,
  300 ms), "Thank you for helping shape Pantas. Your answers go straight to the team." 15/1.45
  (380 ms), tint button "Back to Feedback" 44 px (460 ms). `already-exists` shows this state too.
  `failed-precondition` toast "The survey is closed." Other errors toast "Could not send. Try
  again." and keep answers.

### U4 Reward (FbReward phone, FbDeskReward wide)

When `eligible` or `activated`, the reward card replaces the top days card; the days card moves
below it with the 17 w600 (wide 16) "{n} of 5 days" title only, padding 18 16 4, strip padding 10
12 18 (wide 12 16 18), missed days fill with the number (phone secondary, wide tertiary), no pop
on the phone board, pop with 80 + 60 ms stagger on wide; Exit Survey row "Sent" plus accent check.
- Phone card: radius 18, padding 18 18 20. Crown (24 px, #D9A400, path
  `M3.5 8l4.5 3.5L12 5l4 6.5L20.5 8 19 17.5H5z`) + "You earned 1 year of Pro" 22 w700 (gap 8),
  rise 400 ms at 100 ms; 4 gap; subline "Thank you for testing Pantas. Turn it on whenever you are
  ready." 15 secondary, rise at 260 ms; 16 gap; 12-month strip (6 px bars radius 99 fill, gap 4,
  single-letter labels 10 w500 tertiary, 6 px gap); 18 gap; "Activate 1 Year of Pro" 52 px radius 14,
  rise at 320 ms. Footnote "Activate by Dec 31, 2027. The year covers every exam. If you have paid
  Pro, the year starts when it ends."
- Wide card: radius 16, padding 22 20 20, whole card rises 450 ms. Crown 26 px gap 10, title in a
  28 px clip; subline 15 secondary indented 36; 22 gap; strip 8 px bars gap 6, labels 11 w500
  "Nov".."Oct"; 22 gap; button 44 px min 214 radius 12. Footnote "Activate by Dec 31, 2027. If you
  have paid Pro, the year starts when it ends."
- Month labels start at the reward start month once activated, else the current month.
- Activate: spinner in the button, then: title rolls (old up −100 % and out 360 ms `checkDraw`; new
  "Pro is on until {endsAt: MMM d, y}" in from 100 %, 360 ms riseIn, 80 ms later); crown swings
  1.3 s (`shake`, keyframes 0, 11°, −8°, 5°, −2.5°, 0 at 0/18/38/56/74/100 %, origin 50 % 85 %) at
  550 ms; months fill gold #D9A400 left to right (scaleX 0 → 1, 420 ms shared, 120 + 45 ms each),
  labels to secondary; the button collapses (height 320 ms shared, opacity 200 ms); the line "Turned
  on {activatedAt: MMM d, y}. Every exam is included." rises at 500 ms with a 18 px accent check
  drawing at 600 ms; subline becomes "Thank you for testing Pantas."; footnote becomes "After
  {endsAt: MMM d, y}, your account goes back to Free." Revisits show the on state still.
  Errors: toast "Could not turn it on. Try again."
- The Settings row value after activation stays the day count.

### Undrawn states (lead rulings, flagged to Aedwon for the eye check)

- Exit Survey row: before Nov 15 "Opens Nov 15" with both texts tertiary (as drawn); open and not
  sent: title primary, value "Until Nov 22" secondary, chevron, opens the survey; sent: "Sent" +
  check (as drawn on the reward board); closed and not sent: "Closed", tertiary, not tappable.
- Count over 5 shows "5 of 5 days" (the strip still shows every counted day).
- Sent item page (no board): back "Feedback", 28 px title is the date ("Nov 11, 9:41 PM"), a card
  with the full text (17/1.35) and, below it, each image full width at its aspect ratio, radius 10,
  10 px apart. Image-only feedback has no text card.
- Image-only sent rows show "1 image" (or "{k} images") as the text line and the date alone.
- Errors use the app's existing toast. Refused files: "Use a PNG, JPEG or WebP image." and "Each
  image must be 5 MB or smaller."
- Wide survey progress counts Q7 when filled, so a full form reads 7 of 7 (the board's counter
  stopped at 6).

### Tests (lane U)

Widget tests for: row hidden for non-testers, row card order with and without Beta: Pro Features,
row value; page states (before survey, survey open, survey sent, eligible, activated) on phone and
wide (set a wide test surface as other settings tests do); compose: disabled send, add up to 3,
remove, refused files, send success clears and inserts, send failure keeps the draft; Cmd+Enter
sends on wide; survey: send disabled until 1 to 6, each control, sent state, already-exists, closed;
reward: activation success state and error; reduced motion renders final states immediately
(`MediaQuery(disableAnimations: true)`). Light and dark build without errors.

## Lead verification

Merge D then U, review both diffs against this plan and the boards, then the SUBAGENTS.md Part 5
set with output kept in `docs/superpowers/plans/beta-feedback/verification.md`, `dart run
tool/checks/run_checks.dart`, `flutter build web`, push, CI green, launch-log entry, report to
Aedwon with what to check by eye. No deploy.
