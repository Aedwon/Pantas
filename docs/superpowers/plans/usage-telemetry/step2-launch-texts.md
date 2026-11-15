# Screen counts: in-app update, Settings subtitle and guardian email (revision 2, Nov 15)

Conditions from the Fable 5.2 sign-off (launch log, Nov 15). Drafted by the DS4 lead under process rule 5, critiqued
by Codex GPT 6.1 Sol at high effort (`step2-launch-texts-codex-critique.md`: 6 must, 2 should), revised by the lead.
The guardian email goes to Aedwon first (written rule 6); nothing goes to guardians without his word. The flag stays
off on prod until he says "ship it"; the legitimate interest assessment it rests on is section 3 of
`step2-legal-draft.md`, approved by Fable 5.2 under his delegation.

Codex findings and what was done:
1. (must) Texts promised more than the facts ("your answers", "scores"): now they say only that screen counts have
   no account ID; the Teen and Privacy notices carry the full description.
2. (must) "what helps you most" suggested measuring learning: now "to see which screens are used".
3. (must) Once per device could miss a learner on a shared device: the notice is shown once per learner on each
   device, and counting on that device starts on the learner's next visit after it was shown, so there is time to
   turn the reports off first. Dismissing is a record that the notice was shown, not consent.
4. (must) Repeat counts: the approved notice (section 2a of the legal draft) already says "how many times you opened
   it in that visit"; the in-app text now says "how often". Guardian and age-check screens counted as "other" is a
   data rule, not a notice change (the approved wording stays as Fable approved it).
5. (must) "You don't need to do anything" hid the default and the basis: the email now says the reports are on by
   default, why, how long they are kept, and how to stop them or object, with links to both notices. The Home notice
   links to the notice.
6. (must) "ship it" alone: noted above; the assessment is documented and approved.
7. (should) Subtitle: adopted.
8. (should) Email subject and "a small change": adopted.

## 1. In-app update (a Home notice, once per learner per device, before counting starts)

DS4 Notice on Home, info tone, through the existing Home notice system, web app only. Counting on a device starts on
the signed-in learner's next visit after the notice was shown to them on that device. "Got It" or the close button
dismisses it.

- Title: Screen counts in speed reports
- Text: Our speed and error reports now also count how often you open each screen, to see which screens are used.
  Screen counts have no account ID. You can turn these reports off in Settings, then About.
- Buttons: "Learn More" (secondary; opens the Privacy Notice, or the Teen Notice for an under-18 account, at the
  top: the legal pages have no section links, so it cannot open at "Speed and error reports") and "Got It" (main).

## 2. Settings switch subtitle (Settings > About, the speed and error reports switch)

Old: Helps us find slow screens and errors.
New: Helps us fix slow screens and errors. Includes screen counts.

## 3. Guardian email (revision 3, Nov 15: written rule 8, Aedwon's email shape)

One email per under-18 account's guardian, before counting starts. Rewritten to written rule 8 (short plain subject,
a greeting, two or three short sentences, one button, no bullets, no sign-off, no extra links, no repeated facts,
dates with the weekday) while keeping every fact the Fable 5.2 sign-off requires: what is new, the default, the basis,
retention, how to stop it or object, and both notices. Re-checked by Codex Sol High (`step2-email-codex-recheck.md`).

- From: the existing guardian mail sender.
- Subject: Pantas speed reports
- Body:

  Hi {guardian first name, or "there"},

  From {start date, written like "November 22 (Sun)"}, Pantas speed and error reports will also count visits to
  each screen, sent with {child first name}'s sign-in session. Reports are on by default and kept for 30 days, based
  on our legitimate interest in fixing and improving Pantas. {child first name} can switch reports off in Settings,
  or you can object at dpo@pantas.study, and our Teen Notice and Privacy Notice explain more.

  [Read the Teen Notice] (button, opens {teen notice link})

Codex re-check (`step2-email-codex-recheck.md`): all six required facts present. Applied: finding 1 (the body now
says the reports are sent with the child's sign-in session instead of only "no account ID", so nothing implies
anonymity; shorter sentences). Lead rulings on the rest: finding 2, the button stays one button to the Teen Notice,
the notice that applies to a 13 to 17 learner and their guardian; the Privacy Notice is public at
app.pantas.study/legal/privacy and named in the text, and rule 8 allows no second link. Finding 3 is already met:
every learner sees the in-app update before counting starts, once per learner per device. Finding 4 is already met:
the legitimate interest assessment, including children's interests, is section 3 of `step2-legal-draft.md`, approved
by Fable 5.2 under Aedwon's delegation.

Self-test (written rule 6): the exact final email, personalized for one sample account, goes first to
aerol.balayon@gmail.com only; real sends wait for his confirmation that he received and checked it. Nothing is sent
from this lane.
