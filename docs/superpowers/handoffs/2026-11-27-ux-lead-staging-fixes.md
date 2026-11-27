# UX lead: staging fixes from his Math pilot read (E-205), Nov 27

Policy read: `Aedwon/Pantas` main 5907932e1 (workers read up to 7d71860ff). Lane rules: UI only to Claude workers (3 Sonnet 5.5 workers, at most 2 at once), files changed with Edit or Write, Flutter runs through `flutter-locked.sh`. Hard stop 11:40 PM Manila for the 12:05 AM opening.

Source: his words, verbatim, are in `docs/workflow/process-improvement.md`, entry "Walk-through lesson spacing and nesting found by Aedwon on staging (Nov 27)", plus: "also there's no need for this to be shown to me in a mockup but can we put an "Already have an account? Log in" sort of link for those coming back so they don't experience the onboarding before logging in or something".

## Branch

`ux/walkthrough-staging-fixes-r1` from main 5907932e1. Not merged, not deployed. After the opening, prod web is frozen until the service worker fix passes audit and a 48-hour soak (his "A", Nov 26), so these reach staging first.

## Delivered

1. **Spacing (7fcdb4fb7).** Display maths had 28 above and 8 below in the shared reader stacker (every lesson, old format too); now 28 and 28. A walk-through part after a formula moves from 24 to 28 to match. The pair note moves from 12 to 16 under the Wrong line (measured 14 above, 13.6 below). Widget tests measured the old 8 and 9.6 px gaps failing first (`test/core/ui/components/walkthrough_parts_test.dart`). Margins collapse (max of below and above), so stacked formulas keep 28 between them. Known effect: a solution or example stem that ends in a formula now keeps 28 under it inside its card (was 8 or 18).
2. **Sign out lands on Welcome (e362c2bbb).** Root cause: sign out wiped the account's settings (terms, study days) but kept the device's onboarding-complete and age-gate flags, so the study screen and router sent the student into onboarding at a later step (terms or exam picker). Fix: Sign Out runs the same reset as Delete Account, shared in one helper, then goes to `/onboarding`. Both now also clear the saved age group (a stale `minor` opened the guardian step before Welcome); the minimum-age block stays. The sign-in page's "use another email" path is untouched, so a returning account is not reset there. Test failed first (`test/features/settings/presentation/sign_out_to_welcome_test.dart`). Consequence: a Pro student who signs out and back in goes through onboarding again (age, then the steps whose answers did not sync), as after Delete Account.
3. **"Already have an account? Sign in" (9eb522298).** Under Get Started on the app's Welcome step (phone and wide) and on the web Welcome cover (first web visit). It opens the email sign-in page. Wording settled by the UX lead under rule 4: the app says "sign in" everywhere ("Sign Out", "Sign in with Google", "Sign in with your email."), so "Log in" would add a second word for one meaning. After sign-in, onboarding starts at the age step, not Welcome; the age step stays because it is a per-device check. Tests failed first (`onboarding_sign_in_link_test.dart`, `onboarding_welcome_step_test.dart`, `test/web/pantas_welcome.test.mjs`).
   - Limit: a returning student on a new device still sees the age step, the terms step and the exam picker after signing in. Age group, age gate, chosen exam and onboarding-complete are device prefs and do not sync. Skipping age and terms for a returning account needs a legal and product ruling; restoring them needs a new server field. Not built.
4. **Card in card: board only, nothing built.** The approved board (Lesson Walk-Through Samples, page "New parts, every state", "Try the last step, answer shown") draws the Try card inside the solution inside the example card, so today's build matches the board. `design/system/patterns.md` has no nesting rule. The live app adds one more box than the board: its solution is an inset rounded panel, where the board draws a full-width band. New page on the same canvas, "Try the last step: card in card (pick one)": Today, A (no card, a ruled section at the end of the solution), B (its own card after the example card), C (a teal block with no border, answer inside it). Phone, dark, answer shown. Lead's recommendation: A.

## Verification

- Focused tests for each item pass (workers' runs, all through the lock); `flutter analyze` and `dart format` clean on changed files; `dart run tool/checks/run_checks.dart` all OK at 9eb522298.
- Goldens: the walk-through reader goldens change (spacing). Update run 46018857223 started on the branch; its PNGs must be copied into `test/goldens/` and the full CI run must pass before integration.
- Not yet done: full CI on the branch; a capture sheet of the new spacing for his visual check; his staging check.

## Returning student skips onboarding: account records, proposal and legal read (Nov 28, after the opening)

Manager's success test: a returning student signs in and does not go through onboarding again. Nothing built for this until the manager relays a choice.

What the account already stores on the server (read-only code survey, no hosted reads):
- Terms: `users/{uid}/server/acceptance {version, acceptedAt}` from `recordSetupAcceptance` (named accounts). `version` is the checkbox wording version (2026-11-09), not the legal texts version (2026-11-28). Clients cannot read `server/**` (`firestore.rules`), and no callable returns it.
- Age: nothing for adults (no age, no adult mark). Only former minors have `server/guardianConsent {ageGroup, adultSince, status, ageCheckNoticeVersion}`. The device keeps the age group.
- Exam, exam date, study days: `server/settings` written by `setExamSettings` on web only; no read callable. Name, exam date, study days, terms time and version are account prefs restored by sync for Pro only. The chosen listed exam and "reminders shown" are device only.
- Sign-in runs no restore; the only "data arrived" signal is sync's up-to-date state, Pro only.

Codex GPT 6.2 Sol high read (one run, account b, read-only), verdict verbatim: "terms skip allowed if the same account's valid assent covers the applicable Terms; age skip not allowed on the setup acceptance record alone." Points: the Terms say acceptance is given "when you set up Pantas" and only a material worsening change needs new acceptance (Section 12), so prior assent by the same account carries across devices (Civil Code 1318 to 1319, RA 8792 s16); the privacy policy's "When you set up Pantas, the age screen asks" and the screen's "We only ask this once" would need one qualifying sentence if age is skipped; legacy guardian-confirmed minors exist; the stored version is the checkbox wording, not the documents shown; a restore must not stamp a notice the student never saw; fall back to the full flow when the record cannot be read; keep age blocks, guardian limits and closed accounts.

Proposal (lead):
- Terms skip now: one read callable on named sign-in returns the acceptance record and guardian status (about 2 reads per sign-in, rule 7 fine). Record present and the account not withdrawn or closing: write the local markers from the account's own record and skip Terms. Missing or unreadable: full flow. Going forward the acceptance record also stores the legal texts version shown.
- Age skip needs a new account record: when a named account passes the age check, store its age group (never the age), the notice version and the time on the server, and read it in the same callable. Accounts without it are asked once more, then never again. This is new collection: privacy policy sentence change under rule 5 (agent draft, Codex critique, Aedwon checks) and, once the app is public, the rule 9 email before it takes effect.
- Exam picker, exam date, study days, name: Pro already restores them. For Free, the smallest path is a server copy of those four answers in the same record (native included), read by the same callable; also a privacy-policy-listed collection.
- Recommendation: build terms skip plus the age record and the Free settings copy together, so a returning student sees no onboarding step at all (only Reminders on a new phone, which is a device permission). Estimate: about 1 day build and tests, plus the legal sentence and its Codex critique.

Manager's middle option (Nov 28, about 1:30 AM, for his answer): skip Terms from the account record; save exam, date, days and name on the account only if the Privacy Policy already covers it; keep asking age on each new device, nothing stored (age is sensitive personal information under RA 10173 s3(l), and the policy says the age never leaves the device).

Privacy Policy coverage check (shipped text, `lib/features/legal/domain/legal_document.dart`, version 2026-11-28):
- "What we collect" lists "Study records: your study settings, answers, results, study times, bookmarked lessons and flagged questions." So the data is a disclosed category.
- Where it is kept: "Some records stay in your browser or on your phone. On the web, your answers and study activity also go to our servers, including on Free. ... Pro adds backup and syncing across devices."
- Covered: web (Free and Pro), where `server/settings` already holds exam, date and days; and Pro on any device, which sync already restores.
- Not covered: Free on a phone. The text says those records stay on the phone and that syncing across devices is a Pro feature. Storing and restoring them would need a policy change (rule 5, then the rule 9 email once public) and gives Free part of what Pro sells.
- Name: the Google sign-in name is listed under Account; the name typed in onboarding is a study setting, same coverage as above.
- Not checked: the "How we use" purposes section line by line for a restore purpose.

## Next

1. Copy the CI goldens, push, full CI green.
2. Capture sheet (one sheet, phone dark, before and after) for his spacing check.
3. Staging build after the opening (release lead), then his check of sign out and the Sign in link.
4. His pick on the card-in-card page; build it after he picks.
5. Velocity E-205 actuals when done.
