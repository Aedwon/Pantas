# November 9 legal publication dependencies

These exact published sentences depend on the deferred work below. That work is not implemented in this task.

## 24-month inactivity purge

Teen notice, Study data and account settings:

> Make server study data due for deletion after 24 consecutive months without user-initiated app activity, or earlier when the account is deleted or core consent is withdrawn.

## Protected payment archive

Teen notice, Payment and accounting records:

> Keep necessary books, invoices, receipts, refund records, and supporting transaction records for five years, counted from the day after the applicable return-filing deadline, or from the actual filing date if filed late, for the taxable year when the last entry was made in the books.

> Keep relevant records longer where a pending tax protest, tax-credit or refund claim, or another applicable legal duty requires it.

Teen notice, paragraph following the storage schedule:

> Account deletion does not remove this duty.

The current account-deletion process can erase payment source records before these periods end. This task does not add a protected archive.

## Trial-code expiry

Teen notice, Trial-use codes:

> Keep the keyed identity code and minimum trial-use fact for 730 days from the first trial grant, including after account deletion.

> Do not restart that period when the person signs in, is recognized again, or deletes an account.

> This provides a bounded repeat-trial check across exam cycles without keeping a lifelong identity marker.

> Delete earlier if the trial program permanently ends and the code has no remaining justified purpose.

Terms, Subscriptions:

> The teen notice explains the code’s storage period.

## Verification and release limits

The later lifetime of minimum confirmation evidence is not automated. The published sentence is:

> Keep minimum confirmation evidence while permission is relied on, then for 730 days after the last processing covered by that permission, solely to demonstrate and resolve questions about permission.

The app does not track that last-processing date. This task keeps the evidence without inventing that date. An evidence-expiry process is still needed.

The policy acceptance version stays `1`. The published document versions and guardian notice wording version are `2026-11-09`.

No deployment was performed. The scheduled guardian cleanup and evidence rules require deployment to take effect on hosted data. The cleanup runs hourly and removes records whose seven-day deadline has passed. It does not invent dates or document versions for older confirmation evidence.

The Functions unit tests for guardian retention and email pass. The full Functions command stops on an existing App Check test that cannot bind a local socket in the sandbox. Its emulator phase is not reached. The requested Flutter test groups cannot load for the same socket restriction. Changed Dart files pass static analysis and the layering check passes. The required formatter command cannot write the Flutter SDK stamps in this sandbox.
