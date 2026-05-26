# Study Plan Live Validation Parking Lot

**Date:** 2026-05-21

This document tracks the Spec 6 work that cannot be completed without live project access or production content. Local implementation remains isolated: app.db is user data, content.db is regenerable content only, and Do not sync content.db.

## Skippable External Blockers

- **Live Sanity content:** Add `exam.targetMastery` to the exam document, keep the default at `0.75`, and ensure enough active topics/questions/lessons exist for the Study Plan volume calculation to look realistic.
- **Regenerated assets/seed/content.db:** After live Sanity content is present, run the content seed pipeline and rebuild `assets/seed/content.db`; verify the bundled file contains only regenerable content.
- **Firebase live sync validation:** With real auth and App Check available, validate that plan preference writes use native partial-field updates for `examDate`, `examDateIsProvisional`, `intensityPreset`, and acknowledgement fields.
- **Emulator/CI credentials:** Add Firebase emulator or service-account credentials before promoting the cloud preference gateway checks into CI.
- **Android manual QA:** On target Android hardware, verify `/plan`, the Quiz tab entry, the Today CTA, compressed exam-date messaging, rest-day copy, and narrow-screen text wrapping.
- **Production verification:** Before soft launch, test a release build with production Firebase config, production Firestore rules, and the regenerated `content.db` seed.

## Parked Work

- Live Sanity validation is parked until project access and authored content are available.
- Firebase partial-write validation is parked until live credentials or emulator credentials are available.
- Production release verification is parked until Android QA and regenerated seed content are complete.
