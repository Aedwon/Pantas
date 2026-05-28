# Wrapped Landing Page Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `https://pantas.app/wrapped/<shareId>` real — share-time PNG upload + Firestore doc from the app, a server-rendered Cloud Function landing page with per-share OG tags, in-app revoke, and RA10173 deletion/export coverage.

**Architecture:** Three places, per spec §3. (1) Flutter `lib/features/wrapped/`: generate a 128-bit `shareId` at share time, bake the URL + QR into the PNG, upload PNG to Cloud Storage and write `wrapped_shares/<shareId>`, cache the `shareId`, and expose a "My shared cards" revoke list. (2) Firebase `functions/`: an HTTP `renderWrappedPage` that serves OG-aware HTML + the card image and honours `revoked`; `deleteAccount`/`exportData` extended for the new data. (3) Config: `firebase.json` Hosting rewrite, `firestore.rules`, `storage.rules`.

**Tech Stack:** Flutter, Riverpod, Drift, `firebase_storage` (new dep), `qr_flutter` (new dep), Firebase Cloud Functions (TypeScript, gen-2 HTTP), Firebase Hosting. Function tests follow the existing **source-assertion** pattern (`node --test`, `readFileSync` + regex) — not emulator-based.

**Resolved open questions (spec §8):**
1. **Hosting/domain:** rewrite `/wrapped/**` → `renderWrappedPage` on the default Hosting site; attaching the `pantas.app` custom domain is an ops task, not code.
2. **PNG caching:** the function serves the image itself at `/wrapped/<shareId>/card.png` (no open bucket listing, revocation stays effective) with `Cache-Control: public, max-age=300`.
3. **`shareId`:** client-generated 128-bit (`Random.secure`, 32-char hex). Collision probability negligible at expected volume; no collision handling.

---

## File Structure

**App (Flutter):**
- Create `lib/features/wrapped/domain/share_id_generator.dart` — pure-Dart 128-bit token generator.
- Create `lib/features/wrapped/domain/wrapped_share_url.dart` — pure-Dart URL builder + base-URL constant.
- Create `lib/features/wrapped/domain/wrapped_share_host.dart` — pure-Dart `WrappedShareHost` interface (`publish`, `revoke`) + `WrappedSharedCard` value object.
- Create `lib/features/wrapped/data/firebase_wrapped_share_host.dart` — Firebase impl (firebase_storage + cloud_firestore).
- Create `lib/features/wrapped/presentation/my_shared_cards_page.dart` — hosted-card list + revoke.
- Modify `lib/features/wrapped/rendering/wrapped_png_renderer.dart` — accept `shareId`, draw the real URL + a QR code.
- Modify `lib/features/wrapped/application/wrapped_share_flow.dart` — generate shareId, render-with-url, upload, persist shareId.
- Modify `lib/features/wrapped/application/wrapped_providers.dart` — provider for the host + shared-cards list.
- Modify `lib/features/wrapped/data/user_metrics_artifact_repository.dart` — persist shareId in `markShared`; add `listShared()`; add `setRevoked`.
- Modify `lib/features/wrapped/presentation/share_privacy_sheet.dart` — add the disclosure line.
- Modify `lib/features/wrapped/presentation/wrapped_reveal_page.dart` — pass host into the flow; copy button stays.
- Modify `pubspec.yaml` — add `firebase_storage`, `qr_flutter`.

**Backend (Cloud Functions, TypeScript):**
- Create `functions/src/renderWrappedPage.ts` — HTTP function (HTML + image + fallback).
- Modify `functions/src/deleteAccount.ts` — purge `wrapped_shares` docs + `wrapped/<uid>/*` storage objects.
- Modify `functions/src/exportData.ts` — include the shared-card list.
- Modify `functions/src/index.ts` — export `renderWrappedPage`.

**Config:**
- Modify `firebase.json` — Hosting block with `/wrapped/**` rewrite.
- Create `public/index.html` — generic marketing fallback for the Hosting root.
- Modify `firestore.rules` — `wrapped_shares` rules.
- Modify `storage.rules` — `wrapped/<uid>/*` rules.

**Tests:**
- `test/features/wrapped/share_id_generator_test.dart`
- `test/features/wrapped/wrapped_share_url_test.dart`
- `test/features/wrapped/wrapped_share_flow_test.dart` (fake host + in-memory Drift)
- `test/features/wrapped/my_shared_cards_page_test.dart` (widget)
- `test/features/wrapped/share_privacy_sheet_test.dart` (widget — disclosure line)
- `functions/test/wrapped-page.test.mjs` (source assertions)

---

## Phase 1 — App: shareId, URL, QR

### Task 1: dependencies
- [ ] Add `firebase_storage: ^12.3.2` and `qr_flutter: ^4.1.0` to `pubspec.yaml`; `flutter pub get`.

### Task 2: `ShareIdGenerator` (domain, pure)
- [ ] Test: returns 32-char lowercase hex; two calls differ.
- [ ] Implement with `Random.secure()` filling 16 bytes → hex. Allow injecting a `Random` for deterministic tests.

### Task 3: `WrappedShareUrl` (domain, pure)
- [ ] Test: `WrappedShareUrl.forShareId('abc') == 'https://pantas.app/wrapped/abc'`; `base == 'https://pantas.app/wrapped'`.

### Task 4: renderer embeds URL + QR
- [ ] `render({payload, includeArchetype, shareId})` builds `WrappedShareUrl.forShareId(shareId)`, draws it as the footer text (replacing the hardcoded `pantas.app/wrapped`), and paints a QR for that URL via `qr_flutter`'s `QrPainter` into the bottom-right.
- [ ] Test: rendering with a shareId returns non-empty PNG bytes and does not throw (pixel-level QR assertions are out of scope).

## Phase 2 — App: upload host, share flow, revoke UI

### Task 5: `WrappedShareHost` interface + `WrappedSharedCard` (domain, pure)
- [ ] `WrappedSharedCard { shareId, archetypeId, createdAt, revoked }`.
- [ ] `abstract class WrappedShareHost { Future<void> publish({uid, shareId, archetypeId, pngBytes}); Future<void> revoke({uid, shareId}); }`.

### Task 6: `FirebaseWrappedShareHost` (data)
- [ ] `publish`: upload `pngBytes` to `wrapped/<uid>/<shareId>.png` (contentType image/png); write `wrapped_shares/<shareId>` `{ ownerUid, storagePath, archetypeId, createdAt: serverTimestamp, revoked: false }`.
- [ ] `revoke`: set `revoked: true` then delete the storage object.
- [ ] No test (thin Firebase adapter; covered by source review + the fake in the flow test).

### Task 7: repository — persist shareId, list, revoke
- [ ] `markShared` also writes `shareId` (new required param).
- [ ] `listShared()` → shared (`sharedAt != null`) artifacts ordered by `sharedAt desc`.
- [ ] `setLocalRevoked({userId, examId, artifactId})` — clears `sharedAt`/`sharePlatform` so the local list reflects revocation. (No new column; revocation state of record lives server-side, local list just drops it.)
- [ ] Tests: in-memory Drift — markShared persists shareId; listShared returns only shared; setLocalRevoked removes from list.

### Task 8: `WrappedShareFlow` wiring
- [ ] Constructor takes a `WrappedShareHost` and a `ShareIdGenerator` (defaulted).
- [ ] `renderAndMarkShared`: generate `shareId` → `renderer.render(..., shareId: shareId)` → `host.publish(...)` → `repository.markShared(..., shareId: shareId)`. Return `WrappedShareResult{pngBytes, shareId}`.
- [ ] Test: fake host records the publish; result carries the shareId; repo row has it.

### Task 9: disclosure line
- [ ] `SharePrivacySheet` renders: *"Sharing publishes this card to a pantas.app link anyone can view."*
- [ ] Widget test asserts the text is present.

### Task 10: "My shared cards" page + revoke
- [ ] Provider exposes `listShared()`; page lists cards with a Revoke button → `host.revoke` + `repository.setLocalRevoked` + invalidate.
- [ ] Widget test with a fake host + in-memory Drift: a shared card renders; tapping Revoke calls the host.

### Task 11: reveal page wiring
- [ ] Build `WrappedShareFlow` with the host from the provider; add a nav entry to "My shared cards".

## Phase 3 — Backend + config + rules

### Task 12: `renderWrappedPage` (HTTP)
- [ ] `onRequest` (region `asia-southeast1`). Parse `/wrapped/<shareId>` and `/wrapped/<shareId>/card.png`.
- [ ] Read `wrapped_shares/<shareId>`. If missing/malformed/`revoked` → generic fallback HTML (HTTP 200). Else HTML with `og:image`/`twitter:image` → `/wrapped/<shareId>/card.png`, `og:title`/`twitter:title` archetype-flavoured, `twitter:card=summary_large_image`, the `<img>`, and a store-routing CTA (UA-sniff iOS/Android, else both + note).
- [ ] `/card.png` route streams the storage object with `Cache-Control: public, max-age=300`; revoked/missing → 404.
- [ ] Source-assertion tests in `functions/test/wrapped-page.test.mjs`: region, reads `wrapped_shares`, OG meta tags, fallback on revoked/missing, exported from index.

### Task 13: `deleteAccount` purge
- [ ] After the existing `recursiveDelete(userRef)`: query `wrapped_shares where ownerUid == uid`, delete each doc; delete storage objects under `wrapped/<uid>/` (`getStorage().bucket().deleteFiles({prefix})`).
- [ ] Extend `static.test.mjs`/new test: deleteAccount references `wrapped_shares` and `wrapped/` prefix deletion.

### Task 14: `exportData` shared-card list
- [ ] Query `wrapped_shares where ownerUid == uid`; include `{shareId, createdAt, archetypeId}[]` in the returned payload (`sharedCards`).
- [ ] Test asserts exportData references `wrapped_shares`. (Note: exportData is otherwise a placeholder — see plan tail.)

### Task 15: index export + Hosting config
- [ ] `index.ts`: `export { renderWrappedPage } from './renderWrappedPage.js';`
- [ ] `firebase.json`: add `"hosting": { "public": "public", "ignore": [...], "rewrites": [{ "source": "/wrapped/**", "function": "renderWrappedPage" }] }`.
- [ ] `public/index.html`: minimal generic "Pantas Wrapped" marketing page + store CTA.

### Task 16: rules
- [ ] `firestore.rules` — `match /wrapped_shares/{shareId}`: owner (named user, `request.auth.uid == resource.data.ownerUid` / `request.resource.data.ownerUid`) may create with `revoked == false`; may update only `revoked`→true; reads server-side via Admin SDK (client read `if false`).
- [ ] `storage.rules` — `match /wrapped/{uid}/{file}`: `allow write: if request.auth.uid == uid` (named); `allow read: if false` (served through the function).

## Phase 4 — Verify
- [ ] `flutter analyze`, `flutter test`, `dart tool/check_layering.dart`.
- [ ] `cd functions && npm test && npx tsc --noEmit`.
- [ ] Commit per phase.

---

## Notes / flagged debt
- `exportData.ts` is a **pre-existing stub** (returns a placeholder URL, `byteSize: 0`, builds no real Firestore JSON). This plan only adds the shared-card list per spec §5.2; it does **not** close the broader Spec-10 export gap. Surface to the user.
- No Drift schema change: `user_metrics_artifacts_local.shareId` already exists.
