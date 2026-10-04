# Paywall Live Validation Checklist

> **Pricing superseded (4 October 2026).** Prices, plans, and products in this file are historical. The only current prices are in `docs/pricing.md`. Do not quote or implement a price from this file.

This document tracks Spec 7 work that cannot be honestly completed without external dashboard, store, deployment, or device access.

- **RevenueCat dashboard project:** create the Android project for this app.
- **Google Play IAP products:** create `pro_weekly` (₱29), `pro_monthly` (₱99) and `pro_yearly` (**₱999**); configure the yearly 7-day trial; enable the grace period on `pro_weekly`. **`pro_lifetime` is not created**, removed 3 August 2026.
- **RevenueCat product mappings:** map all three products to entitlement `pro` and expose the current offering.
- **Android RevenueCat API key:** provide it at build/run time with `--dart-define=REVENUECAT_ANDROID_API_KEY=...`.
- **Firebase Functions deployment credentials:** deploy `revenuecatWebhook` and `getProContent` to `asia-southeast1`.
- **RevenueCat webhook shared secret:** set the same secret in RevenueCat and the Firebase Function environment.
- **Play Internal Testing:** upload an internal build and add license testers before purchase validation.
- **Firebase live custom-claim validation:** verify purchase/renewal sets `pro=true` and cancellation/expiration clears it.
- **Sanity Pro-content live validation:** add Pro-tagged content and verify `getProContent` succeeds only for Pro users.
- **Android manual QA:** run purchase, restore, route gate, trial notice, and subscription panel scenarios on Android hardware.
- **production verification:** validate release build, release rules, Function deployment, RevenueCat dashboard setup, and Play purchase flow before launch.

Do not mark any item complete based on local unit tests alone.
