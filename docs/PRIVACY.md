# Privacy Policy — DRAFT v0

**Status:** DRAFT, not yet legally reviewed. Not for publication.
**Last updated:** [auto-update at publication]
**Effective date:** [TBD — pre-soft-launch]
**Legal entity:** [Aerol Balayon, sole proprietor — confirm pending DTI registration]
**DPO:** Aerol Balayon · dpo@aedwon.com
**NPC reference:** [insert post-Task 1 confirmation]

## 1. Scope

This Privacy Policy describes how the CSE/CET Reviewer mobile application ("the App", "we", "our") collects, uses, and protects personal data. It applies to use of the App on iOS and Android.

## 2. Data we collect

| Category | Examples | Source | Purpose |
|---|---|---|---|
| Account identifiers | Display name, email (only when you sign in with Apple or Google) | You | Account sync, support |
| Usage data | Quiz attempts, lesson completions, FSRS review state, streak history | App use | Personalize learning, surface progress |
| Device information | Device model, OS version, app version, language preference | Device | Compatibility, support |
| Crash and performance data | Crash logs, performance metrics (anonymized; no question content, no answers) | App runtime | Stability |
| Purchase data | Subscription tier, transaction status (we do NOT see your payment details) | Apple / Google / RevenueCat | Entitlement |

We do **not** collect: precise location, contacts, photos, microphone audio, advertising identifiers (we do not run ads in v1).

## 3. Anonymous mode

You may use the App without signing in. While anonymous, your data is stored on your device and a temporary anonymous identifier with our backend (Firebase). If you sign in later, we migrate your anonymous data to your account.

## 4. Where data is stored

- **On your device:** encrypted at rest using SQLCipher (AES-256). Key stored in iOS Keychain or Android Keystore (hardware-backed where available).
- **In our backend:** Firebase Firestore in the `asia-southeast1` (Singapore) region. Encrypted at rest by Google Cloud Platform.
- **Payment processor:** RevenueCat handles transaction details. We never see your card.

## 5. Sharing

We share data only with:
- **Google Firebase (Google LLC)** — hosting, authentication, crash reporting (no PII in crash reports)
- **Sanity (Sanity.io Inc.)** — content management; **no user PII** is sent to Sanity
- **RevenueCat (RevenueCat Inc.)** — purchase processing
- **Apple, Google** — payment processing per their store rules

We do not sell your data. We do not use your data for advertising.

## 6. Your rights under RA 10173

You have the right to:
- **Access** your data — use Settings → "Export my data" to receive a JSON file by email
- **Correct** inaccurate data — edit in Settings or contact our DPO
- **Withdraw consent** and **delete** your account — Settings → "Delete my account" (irreversible; takes effect within 30 days)
- **Object** to processing — contact our DPO
- **Lodge a complaint** with the National Privacy Commission (`https://privacy.gov.ph`)

## 7. Data retention

- **Active account data:** retained while your account exists.
- **Deleted account:** purged from active systems within 30 days. Backups age out within 90 days.
- **Attempts older than 18 months:** archived to Google BigQuery (within `asia-southeast1`); aggregate trend data retained in your active account.
- **Crash logs:** 90 days.

## 8. Children

The App is not directed to children under 13. We use a birth-year age gate at onboarding. If we learn we've collected data from a child under 13, we delete it.

## 9. Security

- TLS for all network traffic.
- Firebase App Check on every backend call.
- Firebase Security Rules with 100% test coverage.
- SQLCipher local encryption.
- Annual external penetration testing.
- 72-hour breach notification per RA 10173 to NPC and affected users.

## 10. Changes

Material changes will be notified in-app at least 30 days before taking effect.

## 11. Contact

DPO: Aerol Balayon · dpo@aedwon.com
NPC: complaints@privacy.gov.ph

---

**Disclaimer:** This is a v0 draft for legal review. Final wording and any required additions (e.g., notice of automated decision-making for FSRS, App Tracking Transparency on iOS, specific Apple/Google privacy nutrition labels) must be reviewed by a Philippine data privacy lawyer before publication.
