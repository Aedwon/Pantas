# Public ID privacy draft, approval pending

This draft is not legal copy and is not loaded by the app. Aedwon must approve
the sentences before the lead inserts them into the privacy document.

## Proposed sentences

We give signed-in Google accounts a public Pantas ID. You can share it when you
join a giveaway. We use it to find your account and record giveaway activity.
It does not let anyone sign in or read your study data.

Your data export includes this ID. When you delete your account, we remove its
link to your account and retire the ID. We never give a retired ID to another
account.
We keep a protected account reference to prevent new IDs for a deleted account.
We also keep protected purchase references and published exam dates. This stops
one pass purchase from being reused for a later exam sitting.

## Agent notes

- Only the server allocates the ID. The private ID-to-account mapping is denied
  to all clients. The owner's user document includes the ID.
- The manual DPO export must include the user's root document, including
  `publicId`, and the applicable audit records. No automatic export endpoint
  was enabled. Existing `exportData` stays disabled under W6.
- Retired records keep the public ID, retirement time and a SHA-256 UID digest.
  They contain no raw UID. The digest blocks reallocation during account data
  cleanup before Auth deletion. Include the applicable retirement record in a
  manual export if retirement has already begun.
- `lookupPublicId` is a server operator helper, guarded by W6's admin and App
  Check check and recording every successful or missing resolution. It is not
  exported as a client-callable or public HTTP function. The operator must pass
  verified identity/App Check context from its authorized server workflow.
- Operational DPO processing and operator integration are lead-owned manual
  work. Their actual use has not been verified. Do not claim the draft is
  approved, the legal document changed, or the manual export was performed.
- Pass selection, grant issuance and legal text are outside this helper.
- The pass ownership index uses a SHA-256 receipt reference. Account deletion
  removes its UID and reconciliation time. Only the reference, product/exam
  binding and public sitting/end dates remain, so a verified transfer cannot
  reset the paid sitting after deletion. No client can read this index.
- A manual DPO export also includes the user's pass records and any linked
  ownership entries. Their actual export has not been performed in this run.
