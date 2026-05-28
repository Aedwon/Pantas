# Wrapped Landing Page (`pantas.app/wrapped/<shareId>`) — Design

**Status:** Spec draft (ready for implementation plan — Codex)
**Date:** 2026-06-10
**Parent spec:** `2026-06-10-user-facing-metrics-design.md` (this is the deferred sibling named in §12)

---

## 1. Intent

The user-facing-metrics spec generates shareable 9:16 Wrapped cards as the app's marketing engine. Every card carries a deep link, `https://pantas.app/wrapped/<shareId>`, which the parent spec stubbed (decision #10). This spec defines the destination.

When a viewer sees a friend's shared card on social and taps the link, they land on a single-purpose **conversion page**: it echoes the exact card the friend shared, hooks the viewer with an archetype-flavored line, and routes them to install Pantas.

**Design thesis:** the viewer already saw the rich card as an image in the social post. The page's job is *recognition + a personalized hook to get their own result* — not to reproduce or expand the friend's data. This keeps the privacy surface tight and the local-only metrics architecture intact.

**Out of scope:** the metrics engine, archetype synthesis, trigger stream, and cache tables (all parent spec); notification routing (Spec 9); the Progress dashboard (Spec 11).

---

## 2. Locked Decisions

| # | Decision | Why |
|---|---|---|
| 1 | Page **echoes the shared PNG** (not a structured re-render). Plus `archetypeId` for CTA copy. | Viewer already saw the card; re-rendering adds little but uploads personal stats off-device and breaks the local-only design. Echoing the PNG opens no new content surface. |
| 2 | Hosting is **disclosed, on by default, revocable** — not gated behind a separate toggle. | The funnel depends on the link resolving. A public link requires a host; we disclose it once and give erasure controls rather than add friction. |
| 3 | Hosted card **lives until revoked or account-deleted** (no auto-expiry). | Maximizes funnel longevity. RA10173-defensible: data stays "necessary" while the user keeps it public, and they hold direct revoke + deletion controls. |
| 4 | Page is **server-rendered by a Cloud Function** behind a Firebase Hosting rewrite (not static). | Needs per-`shareId` Open Graph / Twitter-card meta tags so the link unfurls with the card image when the link itself is shared. |
| 5 | Unknown / malformed / revoked `shareId` → **generic marketing-page fallback**. | The link still converts; the generic page is the graceful fallback state, not a dead end. |
| 6 | Backend fits the **existing Firebase stack** (Firestore + Cloud Storage + Cloud Functions). Adds **Firebase Hosting** (not yet configured). | No new infra paradigm; one new Firebase product (Hosting). |

---

## 3. Architecture

The feature spans three places. The parent spec owns everything up to PNG composition; this spec owns making the link real.

```
┌──────────────────────────────────────────────────────────┐
│ Flutter app (lib/features/wrapped/)                       │
│  share flow (amends parent §7.6): + upload step           │
│  "My shared cards" list: revoke action                    │
└───────────────┬──────────────────────────────▲────────────┘
                │ upload PNG + create doc        │ revoke
                ▼                                │
┌──────────────────────────────────────────────────────────┐
│ Firebase backend                                          │
│  Cloud Storage:  wrapped/<uid>/<shareId>.png              │
│  Firestore:      wrapped_shares/<shareId>                 │
│  Cloud Functions: renderWrappedPage (HTTP, OG-aware)      │
│  Hosting rewrite: /wrapped/** → renderWrappedPage         │
└───────────────▲──────────────────────────────────────────┘
                │ GET /wrapped/<shareId>
                │
┌───────────────┴──────────────────────────────────────────┐
│ Viewer's browser (from social post / QR)                  │
│  sees: echoed PNG + archetype hook + install CTA          │
└──────────────────────────────────────────────────────────┘
```

### 3.1 Share-time flow (in-app) — amends parent §7.6

1. User taps Share on a Wrapped reveal → app composes the 1080×1920 PNG (parent §7.5, unchanged).
2. Pre-share "What's on this card?" sheet (parent §7.6) appears. **New:** one disclosure line — *"Sharing publishes this card to a pantas.app link anyone can view."*
3. On confirm: app uploads the PNG to Cloud Storage and writes the `wrapped_shares/<shareId>` Firestore doc. `shareId` is a random, unguessable token (128-bit) generated client-side — cards are not enumerable.
4. App caches `shareId` into the existing `user_metrics_artifacts_local.shareId` column, embeds the `https://pantas.app/wrapped/<shareId>` URL (QR + text) into the card, and hands the PNG to the OS share sheet.

Note: the PNG must be composed **with** the final URL/QR before upload, so the hosted image matches what's posted to social. The `shareId` is therefore generated before composition.

### 3.2 View-time flow (web)

5. Viewer taps `/wrapped/<shareId>` → Hosting rewrite invokes `renderWrappedPage`.
6. Function reads `wrapped_shares/<shareId>`. If found and `revoked: false`, it returns HTML with the card image and per-share OG tags. Otherwise it returns the generic fallback page.

### 3.3 Data model

```
Cloud Storage
  wrapped/<uid>/<shareId>.png         # the shared card image (public-read via function)

Firestore
  wrapped_shares/<shareId> {
    ownerUid:    string,
    storagePath: string,              # wrapped/<uid>/<shareId>.png
    archetypeId: string,              # e.g. "night_owl_sprinter" — CTA copy only
    createdAt:   timestamp,
    revoked:     boolean              # default false
  }
```

**No raw signals or stats leave the device** — only the already-published PNG and `archetypeId`. This preserves the parent spec's local-only / not-synced metrics architecture.

---

## 4. The Web Page

### 4.1 Serving model

A single Cloud Function, `renderWrappedPage`, server-renders the HTML so it can inject per-`shareId` meta tags:

- `og:image` / `twitter:image` → the card PNG (so the link unfurls with the card on X / Facebook / Messenger).
- `og:title` / `twitter:title` → archetype-flavored ("A Night-Owl Sprinter on Pantas").
- `twitter:card` → `summary_large_image`.

On Instagram / TikTok the card travels as an image and the link is tapped from the caption or QR; on link-first platforms the unfurl carries the card. Both paths land on the same page.

### 4.2 Page anatomy (live state)

- The shared PNG, displayed prominently — the recognition moment.
- Archetype-flavored headline from `archetypeId`: *"Your friend is a Night-Owl Sprinter. What are you?"*
- One primary CTA — **Get your Wrapped** — with smart store routing:
  - iOS → App Store
  - Android → Google Play
  - desktop → show both + a QR to open on phone
- Pantas branding/footer. No nav, no secondary actions — single-purpose conversion page.

### 4.3 Page states

| State | Trigger | Renders |
|---|---|---|
| **Live card** | `shareId` found and `revoked: false` | Echoed PNG + flavored CTA (§4.2) |
| **Generic fallback** | `shareId` missing, malformed, or `revoked: true` | Generic "Pantas Wrapped" marketing page + store CTA |

The generic fallback reuses the same store-routing CTA, so even a revoked or stale link still converts — just without the personal card.

### 4.4 Out of scope for the page (deferred)

| Deferred | Why |
|---|---|
| Archetype explainer ("what does Night-Owl Sprinter mean") | Adds a content surface; v1 is image + hook + install |
| Interactivity on the card | Echo is a static image by design (decision #1) |
| CTA A/B testing, install attribution beyond Spec 10 analytics | Post-launch optimization |
| Localization | v1 English, matching the app |

---

## 5. Privacy (RA10173), Revocation & Abuse

### 5.1 Consent matrix

Extends the parent spec's pattern: local writes need no consent; off-device travel does.

| Action | Consent? | Why |
|---|---|---|
| Upload PNG + create `wrapped_shares` doc | **Disclosed, not gated** | Intrinsic to the user-initiated share; one disclosure line in the pre-share sheet (decision #2). |
| Serve PNG publicly via page / OG image | **Disclosed** | Same act — "anyone with the link can view," stated up front. |
| `wrapped_revealed` / install-attribution analytics | **Yes** | Routes through the existing Spec 10 analytics consent gate, unchanged. |

The PNG only contains what the user already chose to publish (it passed their opt-in toggles for exam name / week framing in parent §7.6), so hosting opens **no new content surface** beyond the social post itself.

### 5.2 Revocation & erasure (RA10173 data-subject rights)

- **In-app "My shared cards" list** — each hosted card with a Revoke action. Revoke → set `revoked: true` and delete the Storage object. The link immediately falls back to the generic page.
- **Account deletion** — extend the existing `deleteAccount.ts` to purge all `wrapped_shares/*` docs and `wrapped/<uid>/*` objects for that uid.
- **Data export** — extend `exportData.ts` to include the user's shared-card list (`shareId`, `createdAt`, `archetypeId`).

### 5.3 Abuse & security

- `shareId` is a random, unguessable 128-bit token → cards are not enumerable; viewing requires the exact link.
- **App Check** (already in the stack) gates the upload path so only genuine app installs can create cards.
- **Storage rules:** owner-write only; the public image is served **through `renderWrappedPage`**, not via open bucket listing — no directory traversal / enumeration.
- Upload **rate-limited per uid** to prevent a compromised client from flooding storage.
- No third-party UGC concern — the only content is the user's own generated card.

---

## 6. Cross-Spec Impact

**Amends:**
- Parent spec **§7.6 (share flow)** — inserts the upload step and the disclosure line.

**Touches (additive, no behavior change to existing flows):**
- `functions/src/deleteAccount.ts` — purge hosted cards on account deletion.
- `functions/src/exportData.ts` — include shared-card list in export.
- `firebase.json` — add a Hosting block + rewrite (`/wrapped/**` → `renderWrappedPage`).
- `firestore.rules` — rules for `wrapped_shares`.
- `storage.rules` — rules for `wrapped/<uid>/*`.

**Does NOT change:** the metrics engine, `wrappedTriggerStream`, the archetype/artifact cache tables, Spec 9 routing, or Spec 11.

**Consumes from parent spec:**
- The composed 1080×1920 PNG (parent §7.5).
- `user_metrics_artifacts_local.shareId` column (parent §8.2) — now populated with the real hosted `shareId`.
- `archetypeId` from the resolved artifact payload (parent §7.1).

---

## 7. Testing

### App (Flutter)
- Share flow with hosting: PNG uploaded, `wrapped_shares` doc created, `shareId` cached, URL embedded in card before composition.
- Disclosure line present in the pre-share sheet.
- "My shared cards" list renders hosted cards; Revoke sets `revoked: true` and deletes the object.

### Backend (Cloud Functions, emulator)
- `renderWrappedPage`: live `shareId` → HTML with correct OG tags + image URL.
- Missing / malformed / `revoked: true` `shareId` → generic fallback HTML (200, not 404 — link should still convert).
- `deleteAccount` purges all of a uid's `wrapped_shares` docs + storage objects.
- `exportData` includes the shared-card list.
- Storage/Firestore rules: non-owner cannot write; bucket cannot be listed.

### Web (page)
- Smart store routing: iOS / Android / desktop branches.
- OG/Twitter meta tags validate (link-unfurl preview).

### Out of scope for tests
- Cross-platform unfurl rendering on each social network (third-party-controlled).
- Visual regression on the generic fallback page (designer-iteration churn).
- Real store-redirect behavior (OS/store-mediated).

---

## 8. Open Questions for Implementation (Codex)

1. **Hosting region / custom domain wiring** — `pantas.app/wrapped/*` rewrite vs a subdomain; confirm domain is on Firebase Hosting or fronted by it.
2. **PNG cache strategy at the function** — CDN cache headers for the image vs always reading from Storage; revocation must invalidate.
3. **`shareId` token source** — client-generated 128-bit random is assumed; confirm no collision-handling concern at expected volume (negligible, but document).

(These are implementation-plan questions, not spec-blocking decisions.)
