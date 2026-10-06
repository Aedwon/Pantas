# Draft: Privacy Policy addition for the Pantas ID

Status: draft for Aedwon's approval (October 6, 2026). Goes into the in-app Privacy Policy
(`lib/features/legal/domain/legal_document.dart`) in W3 Task 10 only after he approves it.
Facts it describes: L3-W3 Task 10 and `docs/superpowers/decisions/2026-10-04-giveaways-and-gift-codes-log.md`.

## Proposed new section

**Heading:** Your Pantas ID

**Text:**

When you first sign in with Google, Pantas gives your account a Pantas ID: a random 9-digit
number. It is not made from your name, email, or Google account. You can see it in Settings ›
Account and share it, for example to join a Pantas giveaway on our Facebook page.

Anyone who sees your ID cannot use it to open your account or see your data. We use it only to find
your account when we give you a prize, such as Pro for a set time, and we keep a record of each
time we look it up.

When you delete your account, your ID is deleted and never given to anyone else. It is included
when you ask us for a copy of your data.

## The current Privacy Policy in the app, for context (dated May 23, 2026)

- **Your data.** Pantas keeps your study progress, quiz attempts, mock exam results, preferences,
  and account details so the app can save your work across devices. Regenerable content stays in
  content.db and is not synced as user data.
- **Your RA 10173 rights.** Under RA 10173, you may request access, correction, export, or deletion
  of your personal data. Send export or correction requests to our Data Protection Officer. To
  delete your account inside the app, open /settings/account.
- **Notifications.** The app uses local reminders on your device. Version 1 does not store FCM
  tokens or send server push notifications.

Notes for Aedwon (not part of the text):
- The current policy is short and predates the new design. Its "open /settings/account" line shows
  a route, not a screen name, and its date will change when this section is added.
- The new design also adds a few things the policy does not mention yet: the trial-ending and
  exam-countdown reminders (still local, so the Notifications section stays true), the
  "Help improve the app" usage-data choice, and Wrapped share links. Whether to update those
  sections is your call; the lead can draft them the same way.
