# September 8 Quiz Product-Policy Rulings

**Status:** approved by Aedwon on September 8, 2026.

This is a normative follow-up amendment to the September 7 E03 execution spec, E03 chronological decision log, E04–E14 release plan, ordered execution plan, and development checkpoint on branch `web/e03-e14-contract-correction-r1`. It closes the product-policy items that those documents still label `DECISION REQUIRED`. Where this amendment conflicts with those open-decision sections, this later ruling supersedes them. Historical entries remain historical evidence.

## 1. `interleavedTail` scaling beyond 10 questions — approved option 1

Preserve the approved 70/30 intent for every requested session length `N > 0`.

- Selected-topic target = `roundHalfUp(0.70 * N)`.
- Elsewhere target = `N - selectedTopicTarget`.
- Exact half values round upward.
- Examples: `N=5 -> 4/1`, `N=10 -> 7/3`, `N=20 -> 14/6`.
- The same deterministic rule applies when an all-due session length is not 10.
- Availability shortfalls are handled only through the fallback contract below; they do not silently redefine the ratio rule.

## 2. Fallback outside counted buckets — approved option 2

No question may be served through an unclassified `allQuestions` escape hatch.

- A fallback candidate must first satisfy the already-approved eligibility/classification rules for an existing counted bucket and must be charged to that bucket before selection.
- Existing pre-optimization bucket precedence/tie-breaking remains authoritative; this ruling does not invent a new learning category or reorder bucket policy.
- New-question fallback consumes the same shared local-day new-card allowance already frozen across all quiz surfaces and topics.
- A candidate that cannot be classified into an existing eligible counted bucket is not used merely to fill length.
- If classified eligible supply is exhausted, the session may be shorter than the requested length. Preview/recommendation counts must match the served composition.

## 3. Historical owner/outcome compatibility — approved option 1

Preserve historical rows; do not perform a broad history rewrite.

- Compatibility reads may recognize only documented/provable historical owner or outcome encodings from prior persisted contracts/fixtures and normalize them in memory for current behavior.
- New writes use only the current canonical owner identity and canonical outcome encoding.
- Historical rows are not rewritten solely for normalization.
- Unknown or ambiguous historical encodings are preserved but must not be silently attributed to the current canonical owner/outcome.
- Compatibility must stay within the same authoritative user-data lifetime and must never cause cross-account attribution.

## 4. Historical Resume repair — approved option 1

Forward Resume correctness remains mandatory: every answer must be durably persisted so an interrupted current-format session resumes with exact saved IDs, order, index, and answered state.

For already-existing legacy sessions whose historical rows may be incomplete:

- Reconstruct Resume state only when exact mapping to the saved session/question IDs and authoritative attempt/review data is provable.
- If exact reconstruction is impossible, retire only that legacy session from Resume while preserving its attempt/review history.
- Never infer, approximate, or invent an answer/state merely to keep a legacy session resumable.

## 5. Commercial pricing source of truth — approved deferral

No engineering/store pricing value is frozen by E03–E14.

- Do not select between the repository-carried PHP 149/week reference and conflicting Google/commercial checkpoint figures in engineering implementation.
- No Play, RevenueCat, product, entitlement, or store-pricing mutation is authorized by this ruling.
- Before any commercial/store configuration, the authorized founder/Play lane must reconcile live commercial state and explicitly freeze the pricing source of truth.

## Implementation consequence

The quiz-policy blockers above are closed for engineering. E05/E06 must implement these approved rulings rather than re-open them or preserve current bugs as intended behavior. Pricing remains a deliberately deferred commercial-lane gate and does not authorize any store mutation.

This amendment does not authorize E04.3/E04.4, E05, E06, application-code changes, production-key provisioning, main mutation, deployment, AAB work, or Play actions by itself.
