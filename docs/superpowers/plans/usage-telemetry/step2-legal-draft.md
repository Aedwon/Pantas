# Draft for Aedwon's legal sign-off: anonymous screen counts (usage telemetry step 2)

Status: draft. Built behind a flag that is off; nothing ships until Aedwon signs off this wording and the under-18
question below. Drafted by the DS4 lead (an agent) under process rule 5, critiqued by Codex GPT 6.1 Sol at high
effort for Philippine law (angle: favor Pantas as far as the law allows). Aedwon only checks.

## 1. What changes in the app

For everyone, on by default, the web app's existing speed and error reports also carry anonymous screen counts.
Each count is one line: a screen name from a fixed list, whether that screen was the first or the last one in a
visit, and how many times it was opened in that visit. A report has no account ID and no order of screens beyond
"first" and "last". The existing Settings switch for speed and error reports (Settings, then About) also stops the
counts. Optional usage sharing ("Help improve Pantas by sharing usage data") is unchanged.

## 2. Notice wording (Privacy Notice and Teen Notice, section "Speed and error reports")

Current first sentence of the section's second paragraph stays. Add one sentence after "...locations in our code."
in both notices:

Old:
> To find slow screens and errors, the web app sends short technical reports. They include the app version, whether
> this is a first visit, a return visit or the first visit after an update, your browser family, your screen-size
> group, loading times, and error messages, counts and locations in our code.

New:
> To find slow screens and errors, and to learn which screens are used, the web app sends short technical reports.
> They include the app version, whether this is a first visit, a return visit or the first visit after an update,
> your browser family, your screen-size group, loading times, and error messages, counts and locations in our code.
> They also include screen counts: for each screen you open, its name, how many times you opened it in that visit,
> and whether it was the first or last screen of the visit. Screen counts do not include your account ID or the
> order in which you moved between screens.

Nothing else in the notices changes: the 30-day retention, "on by default", "separate from optional usage sharing",
and the Settings switch sentence already cover the counts.

Version stamp: the Privacy and Teen notice versions (`guardianDocumentVersions` in the app and
`GUARDIAN_DOCUMENT_VERSIONS` in functions/src/guardianConsent.ts) move to the release date, together, in the release
that turns the flag on. Not before.

## 3. Under-18 accounts: does a notice version change need a new guardian confirmation? (Aedwon's legal call)

Facts: a guardian's confirmation records the document versions shown (privacy, terms, teens). The speed and error
reports do not rest on consent: they are on for everyone, carry no account ID, and the notice presents them as
separate from optional usage sharing. The guardian's choice on optional usage sharing does not change.

Options, with costs:
- A. No new confirmation; show the updated notice in the app with its new date. Cost: none for families. Risk: if
  the counts were treated as a material change to processing a guardian agreed to, a regulator could expect notice to
  the guardian, not only an in-app date.
- B. No new confirmation; email each guardian of an under-18 account once that the notice changed, with a link and
  a one-line summary, and no action needed. Cost: one email per under-18 account (self-test first, per written
  rule 6); a small number of guardians may write in.
- C. Ask every guardian to confirm again. Cost: under-18 learners may be paused until the guardian responds, which
  harms them for a change that adds no identity data.

Recommendation: B. The counts carry no account ID and do not rely on consent, so a new confirmation (C) is not
needed and would harm learners; telling guardians once (B) meets the transparency duty with little cost. Aedwon
decides.
