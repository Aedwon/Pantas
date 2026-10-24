# W4 client/server coordination, October 19 evening

Lead technical ruling and handoff request. Policy main5b77018a. Approved PWA spec/plan,
C7-client-ruling and later PWA decision log control. This document is not a second status
tracker. Task states remain in new-design/STATUS.md.

## Immutable handoff inputs

Read-only `origin/web/pwa-staging-r1`2c2332e0a3bbc83fefe88739f9d3581045864b6d contains
roadmap-server953f7f24 and the reviewed catalog/content client. Do not edit Claude-owned
branches. Integrate verified handoffs normally through integration/new-design-r1, preserving
existing source and required final checks. No deployed callable is assumed: Blaze billing,
App Check site key and ADC block staging deployment. Fake/emulator contract tests are valid
engineering evidence, not live acceptance.

## W4e presentation and web runtime seam

The published mock callables are startMock, getMockPaper, controlMock and submitMock. The
server pins paper ids/set ids and owns remainingMs/strict/paused/limitMs and answer snapshots.
Start/resume uses the returned examId and mockId, never a locally reassembled replacement.
Save/pause/resume/discard/submission map to those exact operations. Free eligibility counts
from submission, not start; discard preserves the server paper. A strict clock never pauses.

Only CSE Professional and Subprofessional launch on web; both published blueprints are
roamable single-clock booklets. Use the real overall server clock. Do not invent per-section
limits to satisfy native multi-part models. Preserve native multi-part behavior behind the
existing platform seam. Cursor and flag presentation may remain in the existing feature-local
cache, keyed by original account and mock id; it is not another paper/clock/eligibility owner.
Questions hydrate through the existing content repository, which the C7 hook fills on web.
No duplicated content fetch/cache protocol or edits to core content on the E branch.

The current server accepts client-supplied correctness; the PWA decision log explicitly
accepts self-score manipulation as a limit. It is not a new blocker or permission to change
server scoring here. Client requests still contain only actual original-paper question ids.

### Required Claude-owned result/availability handoff

The current callables do not expose completed-result/history/Free review-visibility records
or the next-eligible timestamp needed by the approved mock card. W4e must not invent callable
names, derive authoritative Pro/Free history from local tables on web, or expose cached Pro
notes to Free. Before dependent production wiring, request and reconcile a server-owned read
contract for completed score/breakdown/history, review visibility and next eligibility. This
is the existing C8 requirement, not a new product feature. Pure result layout may be built
against explicit supplied models while the authoritative reader is pending.

Keep the approved CSE Professional155 test-item decision. The explanatory170-item UI sentence
is still awaiting Aedwon's copy acceptance; do not add it. The staging blueprints remain owned
by the Claude/content workstream and are not rewritten from older W4e placeholder files.

## Proposed W4b/Claude insight ordering

Proposal for the Claude lead: finish the pure-signal extraction and server insight read contract
on Claude-owned work before W4b edits metrics/signals or roadmap/domain paths. W4b can own
client read models, account-bound cache/providers and approved Home/plan layout now against
the published setExamSettings/getRoadmap responses. On web only server-returned Today, Coming
up and History are used; no client fallback computes hidden Pro sections. Keep native behavior
behind the platform boundary. Server insights remain a required dependency for those views,
not an invitation to restore local-only Pro computation. Root will record the accepted order
and exact head before overlapping edits. This proposal is not a claim of Claude approval.

## Integration collisions

Preserve staging's optional fetchHook in storage.dart alongside W4d's eventual data changes.
Preserve staging's web content bootstrap/App Check alongside W4h's startup failure state.
Schema26 arrived on staging with its migration; regenerate ignored database code after any
integration that introduces it before judging checks. No worker merges or history rewriting.


## October21: verified W4e reader and mock answer-feed handoff

Aedwon authorized "all you need to do to complete w4e", then explicitly selected "CSE launch scope". This supersedes the earlier external-reader ownership hold for this bounded dependency. Original staging20692945 is preserved; new server branch web/w4e-server-reader-r1 at0c17bfb0f6874cddb1cbdb807c0510bbd7f959ff is reviewed/tested/uploaded,165plain/205emulator on Node22, exact native review-scheduler parity and clean bridge analysis. No deployed endpoint is assumed. Existing completed-result reader hold above is resolved by this actual source handoff, not a guessed/local authority.

Published source callables (asia-southeast1, named Auth, App Check and limits):
- getMockAvailability({examId,includeSetup?}): actual status available/cooldown/in-progress/no-blueprint, serverNow, nullable accessRecheckAt/nextEligibleAt/lastMockId, current exam-specific proCovered; open identity belongs to the returned account paper, possibly another exam. includeSetup:true supplies server-sampler preview expected/actual counts when available, with no start/write/clock. Actual identity still comes from startMock/getMockPaper.
- getMockResults({mockId}): actual exam/attempt times, end reason, strict/limit/duration, consistent score and ordered section counts, canReview/proCovered/reviewUntil/serverNow/accessRecheckAt. Only reviewable detail contains original paper/answers; only covered Pro contains paid notes. Free review expires at submission+30days, including after Pro lapse.
- getMockHistory({limit?,before?}): bounded newest-first summaries with stable submittedAt+mockId cursor; no paper/answers/notes. Follow all pages, reject repeated ids/cursors, bind each request/publication to original identity.
- updateMockReview({mockId,questionId,missReason?,blankReason?,reasonNote?}): current covered Pro and original-paper membership, atomic bounded reason/note replacement.

Use server time plus monotonic elapsed time for rechecks, with browser-safe timer segments. Retry invalidates the authoritative reader, not only derived presentation providers. Existing start/save/pause/resume/discard/submit names remain; server writes reject duplicate/foreign paper ids while retaining the accepted client-correctness trust limit. Recency is the last two submitted papers for the requested exam; Free availability remains account-global.

D-258 is implemented on this server source: mock submission/strict expiry and one internal mock:{id} C9 batch/totals/review-state write are atomic and idempotent. Colon is outside public C9 ids, so clients cannot preempt the internal record. Blank selections create no invented answered questions/reviews. Historical recovery cannot rewind newer reviews. The unchanged native scheduler runs through the shared Dart bridge; current C7 version1 semantics are reused. Ordinary C9 reviews advance existing mock-created state, while broader ordinary seeding/insights remain C10-owned. Server roadmap reads actual due states before end of Philippine day and validates cached answerSessions against current totals. W4b/W4d client work must preserve this feed and invalidate/refresh their server-derived plan at the terminal-session boundary; it must not restore local-only web authority.

Client source f9c28374 wires these models without local web attempt/result writes; actual server access controls paid notes/review. The existing MockCard slot is reconciled as a bounded W4e dependency, without completing unrelated W4d layout/Reviews controls. Future D integration preserves serverMockId/serverExamId/nextOpensAt and the web30day/native14day card contract; do not restore the older D caller's local14day web date. Cursor/marks remain feature-local original-account+mock cache only. Missing original content is recoverable, never evidence to shorten the paper or infer retirement. Other-exam rebuilt finales are explicitly deferred by the CSE launch selection.

Global server/web/PayMongo/content-cache integration remains later in Aedwon's critical path. Rebuild the existing compiled Dart bridge after any change in its source closure and regenerate ignored database code after merged schema changes before judging checks. Preserve source/remote identity, named-account entry ownership and the later human phone/live-staging acceptance gates. App source is entering the agreed development branch under final combined checks; STATUS records the actual acceptance result.

## C3 web purchase gateway handoff for W4f Task 6 (October 24, Claude lead)

Source: `web/paymongo-r1` at b0946994 (pushed; not integrated into `integration/new-design-r1`).
Plan: `docs/superpowers/plans/pwa-launch/C3-web-purchase-gateway.md` on that branch. Minimal
scope (Aedwon's choice). Checks at b0946994: full Flutter 4032 pass, paywall and tool tests 533
pass, Functions 118 plain / 143 emulator pass, tsc, format, layering and attribution clean;
`flutter analyze lib test` has one known `onReorder` deprecation from the branch's older base,
already fixed on integration. Real PayMongo checkout, deployed App Check and browser calls are
unverified until C5 (needs Blaze on pantas-staging and PayMongo test keys).

What Task 6 calls:
- `WebPaymentGateway implements RevenueCatPassGateway` (`lib/features/paywall/data/
  web_payment_gateway.dart`). On web, `revenueCatGatewayProvider` builds it (flag
  `paymentsOnWebProvider`, default `kIsWeb`); mobile construction is unchanged.
- `currentOffering()`: plans and prices from the `listWebPlans` callable (server
  `products.json`, the price checkout charges); price strings come formatted from the server.
  Passes without a published sitting are omitted.
- `purchase` / `purchasePass`: calls `createPaymongoCheckout` and sends the tab to PayMongo.
  When the tab opens it returns `failure(operationAlreadyInProgress)`; the page should treat that
  as "redirecting", not as an error.
- `handleCheckoutReturn(Uri)` (web only; downcast the gateway): call it on `/pro` load. Null means
  not a return; `userCancelled` means cancelled; `success` means Pro active; `entitlementNotActive`
  means paid but not confirmed yet (webhook lag; no polling in minimal scope).
- `startTrial()` (web only): `WebTrialResult{status: started|notAvailable|failed, operation}`.
- `restorePurchases()`: token refresh plus a grant ledger read.
- Anonymous accounts get `permission-denied` from checkout (mapped to `configurationFailure`):
  do not offer checkout or the trial to them.
- A grant that lands after a pending return shows on the next restore or login.
