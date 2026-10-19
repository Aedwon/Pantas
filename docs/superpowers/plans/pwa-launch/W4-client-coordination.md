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
