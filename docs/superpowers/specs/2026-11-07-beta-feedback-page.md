# Feedback (Beta) page, reward progress, exit survey and reward activation

Date: November 7, 2026. Lead: Claude (Opus 5.5). Policy read: origin/main 6c0f79cc0.
Code base: `web/visual-check-fixes-r1` at 943411098; work branch `web/beta-feedback-r1`.
Complexity: balanced plus attachments (Aedwon, Nov 7: "balanced is approved + attachments").
Decision record: `docs/superpowers/decisions/2026-10-19-pwa-launch-log.md`, Nov 7 entries.
Supersedes, for the beta reward only: the reward rules in pantas-web
`docs/superpowers/specs/2026-10-25-pwa-beta-signup-design.md` ("5 of the first 7 days after first
login", "grant within 14 days", "exit survey sent by email on day 7").

## Part A. For Aedwon (plain language)

What testers get, all on one new Settings page called **Feedback (Beta)**, shown only to selected
beta testers:

1. **Send feedback.** A text box plus up to 3 images (screenshots). One tap sends it. Sending works
   during and after the beta week.
2. **Sent feedback.** A list of everything they sent, newest first, with the images. They can open
   each one. They cannot edit or delete it (they can still ask dpo@pantas.study to delete data).
3. **Reward progress.** "3 of 5 days" with the seven beta days, Nov 9 to 15, shown as marks.
4. **Exit survey.** Opens Nov 15 at 12:00 a.m. and closes Nov 22 at 11:59 p.m., Philippine time.
   Seven short questions. Their sent feedback is shown beside it so they can refer to it. One
   submission; it cannot be changed after sending.
5. **Activate 1 year of Pro.** Appears once they have 5 days and a sent survey. They choose when.
   Deadline: Dec 31, 2027, 11:59 p.m. Philippine time. The year covers every exam. If they have paid
   Pro when they activate, the year starts when the paid time ends.

Reward rules (decided Nov 7):

- A day counts when the tester finishes **the whole Today plan** for that day, as it was set at the
  start of the day. Extra work added after finishing ("keep going") is not needed.
- On a **rest day** there is no plan, so finishing any Today topic, interleaved or new-questions
  session with every question answered counts for that day.
- Only Nov 9 to 15, Philippine time. Each date counts once. 5 of the 7 dates are needed.
- The app reports a finished day to the server the moment it happens; the server uses its own clock
  for the date. A day finished offline counts only when it reaches the server the same Philippine
  date. This is the accepted limit of a 20-person beta.

Survey questions (from the SSOT tester kit's exit survey topics):

1. How often did you use Pantas this week? (Every day / Most days / A few days / Once)
2. How easy was Pantas to use? (1 to 5)
3. How useful was Pantas for your exam preparation? (1 to 5)
4. Will you keep using Pantas after the beta? (Yes / Maybe / No)
5. How likely are you to recommend Pantas to a friend? (0 to 10)
6. What should we improve most? (text, required)
7. Anything else you want to tell us? (text, optional)

Not included: editing or deleting feedback in the app, replies from Pantas inside the app, an admin
screen (Aedwon reads feedback in the Firebase console), video or file attachments.

Costs and risks: about 1.5 days of build. Images use Firebase Storage on pantas-prod (5 MB per
image, 3 per feedback). Day reports come from the tester's device, so a determined tester could
fake them; accepted for this beta. The design must be approved on its board before the screens are
built, and they will match it 1:1.

How completion is judged: a selected tester on app.pantas.study can send text and images, see them
listed, see their day count rise after finishing a Today plan during Nov 9 to 15, submit the survey
in its window, and activate the year once eligible. Non-selected users never see the page. Server
tests cover every rule above.

## Part B. Agent section

### Server (functions, pantas-prod, region asia-southeast1)

Every callable follows `betaPro.ts`: `onCall({region, enforceAppCheck, consumeAppCheckToken})`,
`assertFreshAppCheck`, `assertNamedUser`, input validation, `allowAtMost`, then
`selectedBetaApplication` (selected, verified email). Philippine dates use Asia/Manila (+08:00).

- Window constants in one module (`betaReward.ts`): beta days `2026-11-09`..`2026-11-15`;
  survey opens `2026-11-15T00:00:00+08:00`, closes `2026-11-23T00:00:00+08:00`; activation
  deadline `2028-01-01T00:00:00+08:00`. Constants, not env config.
- `sendBetaFeedback({feedbackId, text, attachments: [{path, contentType}]})`: text 1..4000 chars
  after trim, or empty text with at least one image; up to 3 attachments; each path must be
  `betaFeedback/{uid}/{feedbackId}/{0|1|2}` and exist in Storage with an image content type and
  size <= 5 MB (check with the Admin SDK). `feedbackId` is a client-generated 20-32 char
  `[A-Za-z0-9]` id; idempotent: a repeat call with the same id returns the stored doc without
  writing. Writes `users/{uid}/betaFeedback/{feedbackId}`:
  `{text, attachments: [{path, contentType, size}], createdAt, userAgent (client-sent, <= 300
  chars), appVersion (client-sent, <= 40 chars), examId (client-sent, optional)}`.
  Limit: 40 per day per uid.
- `recordBetaDay({kind: 'plan' | 'restDay'})`: server date = Asia/Manila date of now. If outside
  the 7 beta days, return `{recorded: false, reason: 'outside'}`. Otherwise add the date to
  `users/{uid}/betaReward/state.days` (array of `YYYY-MM-DD`, set semantics) in a transaction.
  Returns `{recorded, days}`. Limit: 20 per day per uid.
- `submitBetaSurvey({answers})`: only inside the survey window; validates each answer against
  the question list above (enums, 1-5, 0-10, required text 1..2000, optional text <= 2000); one
  submission only (`already-exists` on repeat). Writes `users/{uid}/betaReward/survey`
  `{answers, submittedAt}` and sets `state.surveyAt`.
- `activateBetaReward({})`: requires `days.length >= 5`, survey submitted, now < deadline, not
  already activated. Creates one grant through the existing grants path with a new
  `source: 'beta_reward'`, covering every exam, 365 days (calendar year from start: start + 1
  calendar year in Asia/Manila), queued after paid coverage with the existing
  `stackable`/`reanchorQueued` logic so it starts when paid Pro ends. Sets
  `state.activatedAt` and `state.grantId`. Refresh entitlement claims the way `betaPro.ts` does.
  The beta Pro grant (`source: 'beta'`) is not changed. The grant must not count against trial
  eligibility (same rule as beta grants).
- `getBetaReward({})`: returns `{days, surveyOpen, surveyClosesAt, surveySubmitted, eligible,
  activatedAt, activationDeadline, proUntil}` for the page. Or the client reads the owner-readable
  docs directly; pick one and keep it consistent (callable preferred, so App Check applies).
- Firestore rules: `users/{uid}/betaFeedback/{id}` and `users/{uid}/betaReward/{doc}` owner read,
  no client write. Storage rules: `betaFeedback/{uid}/{feedbackId}/{n}` with `n` in 0..2,
  signed-in owner create only (no update, no delete), `request.resource.size <= 5 * 1024 * 1024`,
  content type `image/(png|jpeg|webp)`; owner read (for the list thumbnails). Rules tests for
  each.
- Tests: unit tests per callable (window edges at +08:00 midnight, idempotency, attachment
  checks, eligibility, deadline, queuing after a paid grant), rules tests, and `npm test` green.

### Client (Flutter, web first; native must compile)

- Visibility: a **Feedback (Beta)** row in Settings for `betaAccessProvider == true`, including
  after Nov 16. Position, labels, states and motion come from the approved board. Also add it to
  the wide-web settings layout (`AccountPage` path) per the board.
- Route `/settings/beta-feedback` in both the web and native settings route lists.
- Image picking on web: add one maintained picker package if none fits; prefer `image_picker`
  (has web support). Downscale only if the board calls for it; otherwise upload as picked and
  refuse files over 5 MB with a clear message.
- Upload each image to `betaFeedback/{uid}/{feedbackId}/{i}` before calling
  `sendBetaFeedback`; on failure keep the draft, show the error, allow retry with the same
  `feedbackId`.
- Day reporting: when `DaySnapshots.originalDone` first becomes true for today's snapshot, call
  `recordBetaDay(kind: 'plan')` once per local day (remember the sent date locally to avoid
  repeats). On a rest day, call `recordBetaDay(kind: 'restDay')` after a streak-eligible session
  completes (`SessionOrigin.isStreakEligible` and `session.isComplete`). Only for selected testers
  and only Nov 8 to Nov 16 local time (server decides the real date). Failures are silent and
  retried on next app open the same day.
- Survey, progress and activation UI per the board. All copy follows `AGENTS.md` voice rules.
- Tests: widget tests for each state on the board, the day-report trigger (plan done, rest day,
  not repeated), and the hidden state for non-testers. `flutter analyze` clean,
  `dart run tool/checks/run_checks.dart` clean.

### Site and emails (pantas-web)

After the app ships: tester guide "Feedback and help" points to Settings, then Feedback (Beta);
reward text uses the rules above; survey text says it opens in the app on Nov 15. Email copy as
approved on the review canvas.
