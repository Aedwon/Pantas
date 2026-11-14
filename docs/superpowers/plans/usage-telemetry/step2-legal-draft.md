# Draft for Aedwon's legal sign-off: screen counts in the speed and error reports (usage telemetry step 2)

Status: draft, revision 2 (Nov 14). Built behind a flag that is off; nothing ships until Aedwon signs off the wording
in section 2 and picks an option in section 4. Drafted by the DS4 lead (an agent) under process rule 5, critiqued by
Codex GPT 6.1 Sol at high effort for Philippine law (angle: favor Pantas as far as the law allows; critique in
`step2-legal-codex-critique.md`), revised by the lead. Aedwon only checks.

Codex findings applied: (1, must) the counts are not called anonymous, because a report arrives with the sign-in
session; (2, must) the lawful basis line names the new purpose, and a short legitimate interest assessment is in
section 3; (3, should) the sentence on order no longer makes an absolute promise; (4, should) the claim that the
existing retention and Settings wording covers the counts is now a build requirement checked by tests (section 5);
(5, must) the under-18 recommendation is tied to legitimate interest and adds an in-app update for everyone.

## 1. What changes in the app

For everyone, on by default, the web app's existing speed and error reports also carry screen counts. Each count is
one line: a screen name from a fixed list, whether that screen was the first or the last one in a visit, and how many
times it was opened in that visit. A report has no account ID field and no order of screens beyond "first" and
"last". Like the rest of the report, it is sent with the sign-in session (also a guest session) so the server can
check the request and limit how many reports arrive; the session is not written to the stored report. The existing
Settings switch for speed and error reports (Settings, then About) also stops the counts. Optional usage sharing
("Help improve Pantas by sharing usage data") is unchanged.

## 2. Notice wording (Privacy Notice and Teen Notice)

### 2a. Section "Speed and error reports", first paragraph, both notices

Old:
> To find slow screens and errors, the web app sends short technical reports. They include the app version, whether
> this is a first visit, a return visit or the first visit after an update, your browser family, your screen-size
> group, loading times, and error messages, counts and locations in our code.

New:
> To find slow screens and errors, and to learn which screens are used, the web app sends short technical reports.
> They include the app version, whether this is a first visit, a return visit or the first visit after an update,
> your browser family, your screen-size group, loading times, and error messages, counts and locations in our code.
> They also include screen counts: for each screen you open, its name, how many times you opened it in that visit,
> and whether it was the first or last screen of the visit. Screen counts contain no account ID and show no order
> of screens beyond which screens were first and last.

The rest of the section stays as it is (no account ID or IP address field, the sign-in session used to check
requests, 30-day log retention, on by default, separate from optional usage sharing, the Settings switch).

### 2b. Section "Why we may use your data", the speed and error reports line

Privacy Notice, old:
> Speed and error reports, security records and trial codes: our legitimate interest in keeping Pantas working, safe
> and fair (Section 12(f)). We keep each to what we need.

New:
> Speed and error reports, security records and trial codes: our legitimate interest in keeping Pantas working, safe
> and fair, and in learning which screens are used so we can improve them (Section 12(f)). We keep each to what we
> need.

Teen Notice: the same added clause, "and in learning which screens are used so we can improve them", after "safe
and fair" in its matching line.

### 2c. Version stamp

The Privacy and Teen notice versions (`guardianDocumentVersions` in the app and `GUARDIAN_DOCUMENT_VERSIONS` in
functions/src/guardianConsent.ts) move to the release date, together, in the release that turns the flag on. Not
before. Earlier guardian confirmation records keep the versions they were given.

## 3. Legitimate interest assessment (short, for the record)

- Purpose: learn which screens are used, opened first and left last, to decide what to fix and improve.
- Necessity: per-screen counts per visit are the least data that answer it; no account ID, no full sequence, no
  free text, no answers or lesson content. Optional usage sharing gives more detail only to those who opt in.
- Balancing: the counts are low in detail, kept 30 days, stopped by the existing Settings switch, and described in
  plain words in both notices, including the Teen Notice. They hold no education records or sensitive data (a screen
  name such as "quiz" or "progress" says where someone was, not how they did). Learners 13 to 17 are covered by the
  same switch and the same low detail.
- Alternative considered: counts only from those who opt in. It leaves the question unanswered for most users, which
  is the reason for this change; optional usage sharing stays for richer data.

## 4. Under-18 accounts: does the notice change need a new guardian confirmation? (Aedwon's legal call)

Facts: a guardian's confirmation records the document versions shown (privacy, terms, teens). The speed and error
reports rest on legitimate interest, not consent, and the notices say so. The guardian's choice on optional usage
sharing does not change.

Options, with costs:
- A. No new confirmation; the updated notice shows a new date in the app. Cost: none for families. Risk: a new purpose
  shown only as a date change may not meet the duty to inform data subjects of a change in purpose.
- B. No new confirmation; before collection starts, show an in-app update to everyone (learners and, through the
  guardian email, guardians of under-18 accounts) that says screen counts are added and how to turn them off. Cost:
  one in-app notice and one email per under-18 account (self-test first, per written rule 6); a few guardians may
  write in.
- C. Ask every guardian to confirm again. Cost: under-18 learners may be paused until the guardian responds, which
  harms them for a change that adds no account-linked data and does not rely on consent.

Recommendation: B. The counts rest on legitimate interest, so a fresh confirmation (C) is not required and would
harm learners; telling everyone before collection starts, including guardians, meets the duty to inform. If Aedwon
prefers that the counts rest on consent instead, they must move under optional usage sharing and this draft no
longer applies.

## 5. Build requirements that make this wording true (checked by tests before the flag can turn on)

- The Settings switch for speed and error reports stops the counts (test: counts never sent with the switch off).
- Counts ride in the same report and the same log as speed and error reports, so the 30-day retention applies.
- A report carries only screen name, first, last and count per screen; no account ID field and no order field
  (validator test on the server rejects anything else).
- The flag defaults to off; with it off, no count is collected or sent (test).
