# Mock Resume Correctness Decision Log

## 4 September 2026: Repair complexity

### Context

The beta candidate has three release-blocking mock resume defects. Live progress is not written to the database. Resume lookup uses the signed-in account ID instead of the device-local mock ID. The Resume action opens a normal quiz session.

### Options

1. Minimal: connect the existing persistence and resume seams with the smallest route changes. This is faster, but it gives weaker coverage of app restart and sectional timing.
2. Balanced: reconcile the release state, trace the full lifecycle, add a focused restart reproduction, then repair the existing seams with tests. This covers the release-critical behavior without a database migration or broader architecture work.
3. Hardened: add a wider device and process-death test matrix and redesign the persisted session model. This adds release time and migration risk.

### Recommendation

Use balanced complexity.

### Aedwon

> which do you recommend?

> proceed with balanced

### Decision

Use balanced complexity. Stop after the defect ledger and repair design for approval. Write the failing reproduction before production changes after approval.

## 4 September 2026: Repair design approved

### Aedwon

> Approved. Proceed with the bounded mock-resume correctness repair using TDD exactly as designed.

### Decision

Implement the approved repair. Reuse the existing persistence scheduler and flush path. Prove that the device-local mock identity is cleared during the supported account transition before using it for resume lookup. Preserve the RevenueCat repair line and do not rebuild or upload the signed Android bundle yet.
