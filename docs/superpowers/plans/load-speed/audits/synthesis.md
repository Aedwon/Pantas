# Load-speed audit synthesis (Nov 7, 2026, source 571eea1aa)

Inputs: astra-client.md (A-C), astra-server.md (A-S), opus.md (O), prior-sol-review.md.
All three agree nothing measures startup phases today; most gains are estimates.

## Agreed by two or more auditors

| Item | Refs | Gain | Effort | Risk |
|---|---|---|---|---|
| Startup timing marks + one consent-gated Analytics event | A-C F6, O F4 | turns estimates into measurements | 1-1.5 h | none |
| Start Remote Config right after Firebase init, await at same place | A-C F4, O F7 | 0.4-0.7 s first open of a sitting | 0.25-1 h | none |
| Start the beta check during bootstrap (same provider) | A-C F8, O F2 | 0.5-1.5 s, 2-5 s cold | 1-1.5 h | low |
| Overlap the web entitlement read with content restore | A-C F7, O F9 | 0.2-0.4 s (+token mint) | 1-2 h | low, identity-order tests |
| Versioned build folder, drop 4 s worker wait | A-C F1/F2, O F5/F11 | 0.5-4 s first visit after deploy | 3-8 h | medium, defer |
| Lazy content replay / selected-exam startup | A-C F3, A-S F8, prior #1 | 1-6 s est. heavy users | 8-16 h | high, after beta |

## Single-auditor, verified as worth taking

| Item | Ref | Evidence | Effort |
|---|---|---|---|
| Add ingestSession, recordLessonRead, getSessionDiagnosis, advanceRoadmap to warm list | O F6 | MEASURED cold 2.5-3.4 s vs warm 0.18 s | 0.25 h |
| s-maxage on no-cache Hosting files (CDN purged on deploy) | O F3 | MEASURED MISS vs HIT, 0.2-0.7 s tails | 0.25 h |
| Home loader runs up to 3 times on cached then network plan | O F8 (A-S notes it too) | code trace | 1.5-2 h |
| Observation flush scans full history; double ingest after quiz | O F12, A-S F9 | code trace | 1-1.5 h |
| Single-flight content ceiling refresh (50 reads each) | A-S F7 | free-tier read budget | 3-5 h |
| Coalesce duplicate content fetches | A-S F6 | code trace | 3-5 h |
| Inline the four head helper scripts | O F11a, A-C F1 | one RTT before logo | 1 h |
| modulepreload Firebase JS (first visit) | O F10 | measured module sizes | 0.5 h |

Keep CanvasKit on gstatic (O F10 measured faster, 1-year cache, no Hosting quota).
No minInstances (about $8/function/month).

## Needs a board (visible change)

Release the splash at Home's first frame into the existing skeleton (O F1). Biggest
perceived gain (1-4 s on return visits) but changes what students see.
