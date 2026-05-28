# Spec 11 (Progress) — Amendment Design

**Status:** Amendment draft
**Date:** 2026-06-10
**Amends:** `docs/superpowers/specs/2026-05-16-mvp-roadmap-design.md` § "Spec 11 — Progress"
**Companion spec:** `docs/superpowers/specs/2026-06-10-user-facing-metrics-design.md`

---

## 1. Why this amendment exists

Spec 11 (Progress) was defined in the MVP roadmap with three open questions and a paywall posture that conflict with the user-facing metrics spec published the same day. Rather than edit Spec 11 in place, this amendment documents the deltas — the original Spec 11 text stays as the historical record.

This amendment closes Spec 11's open questions, redefines its monetization posture to match the locked Free vs Pro principle, and clarifies its data source (the new metrics signals layer).

---

## 2. Amendments to Spec 11

### Amendment A — Aggregation strategy (closes Spec 11 open question #1)

**Original text:** "Aggregation strategy: compute on-demand when viewing, or pre-compute on every attempt-completion into a `progress_cache` table?"

**Amendment:** Progress dashboard does **NOT** maintain its own `progress_cache`. Progress consumes the metrics signals layer (`metricsSignalProvider(signal, window, examId)`) defined in the user-facing-metrics spec. The signals layer is the single source of derived metrics across the app.

**Rationale:** A separate `progress_cache` would double-compute the same aggregates and risk drift between Progress and Home/Wrapped surfaces. Sharing the signals layer guarantees consistency — "Wordsmith" on Home and "Subject affinity: Grammar" on the Progress dashboard mean the same thing because they read the same signal.

### Amendment B — Trend window (closes Spec 11 open question #2)

**Original text:** "How far back does the trend view go (all-time, last 90 days, last 30 days)?"

**Amendment:** Window per surface follows the user-facing-metrics spec's window table:
- Current-state panels (per-subject accuracy, per-topic mastery) → **rolling-30d**.
- Retrospective panels (trend lines, prep-history charts) → **prep-window**.
- Achievement panels (best mock, longest streak, total cards reviewed) → **all-time**.

No single global "trend view" window. Window is per-panel and matches the user's intent for that panel.

### Amendment C — Score-impact narrative (closes Spec 11 open question #3)

**Original text:** "Score-impact narrative: rule-based templates from topic mastery, or richer model?"

**Amendment:** Rule-based templates for v1. Same approach as the user-facing-metrics spec's archetype synthesis copy — deterministic templates filled with the user's actual numbers. No LLM. Template engine reuses the same pattern (`{placeholder}` substitution against signal outputs).

**Rationale:** Deterministic copy is testable, debuggable, and doesn't introduce a runtime model dependency. Richer models can replace templates later without changing the surface contract.

### Amendment D — Free vs Pro posture (REVISES original)

**Original text:** "Pro views show a paywall teaser when free user opens them."

**Amendment:** Free vs Pro for the Progress dashboard splits along **content type**, not along feature access:

| Content type | Free | Pro |
|---|---|---|
| **Identity content** (archetype labels, signal stats, Wrapped artifact previews surfaced in Progress) | Full surface | Full surface + Pro depth widgets inline |
| **Analytical dashboard content** (trend lines, weakness narrative, score-impact analysis, per-mock comparison) | Teaser only | Full surface |

**Rationale:** Identity content is the marketing engine — pay-walling it kills viral spread. Analytical content is legitimate Pro upsell. The two halves of Progress are gated differently.

**Concrete change in the surface:**
- A Free user opening Progress sees: their archetype, their atom-equivalent signal stats, links to their past Wrapped artifacts (if any), and **teaser previews** of trend lines and weakness narratives with a "Unlock with Pro" affordance.
- A Pro user sees the above plus: full trend lines, weakness narrative, score-impact projections, per-mock comparison panels.

### Amendment E — Data source documentation

**Addition:** Spec 11 now explicitly depends on `lib/features/metrics/` providers. Add this to Spec 11's dependency list:
- `metricsSignalProvider` for all panel data
- `currentArchetypeProvider` for the archetype block
- `user_metrics_artifacts_local` (read-only) for the past-Wrapped history surface (Pro)

### Amendment F — Phase 2 carve-outs

The following Spec 11 features are explicitly deferred to a future Phase 2 amendment (out of scope for the v1 Progress dashboard):

- Per-mock archetype evolution view (would require per-mock signal snapshots — additive).
- In-app history view for Pro users to revisit past Wrapped artifacts (display surface, not engine work).

---

## 3. Open questions remaining after this amendment

None. Spec 11's original three open questions are closed by Amendments A, B, C. Amendment D resolves the monetization posture. Amendments E and F clarify dependencies and phasing.

---

## 4. What does NOT change

- Spec 11's core scope: Progress remains a dashboard surface for analytical views of user data.
- Spec 11's dependencies on Spec 3 (synced data), Spec 6 (Study Plan exam-pace indicator), Spec 7 (entitlement gate for Pro panels).
- Spec 11's roadmap slot (Week 4 of the MVP critical-path schedule).

---

## 5. Implementation guidance

When Spec 11 enters implementation, the plan should:
1. Import providers from `lib/features/metrics/providers/` — no parallel aggregation logic.
2. Build the entitlement gate around **panel content type**, not panel access. Free users see all panels; some panels render teasers instead of full content.
3. Implement teaser components as a separate widget family (`PaywallTeaserPanel`) used wherever a Pro-gated analytical panel appears.
4. Past-Wrapped history surface (Pro) reads `user_metrics_artifacts_local` directly.
