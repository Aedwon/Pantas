import { getFirestore } from 'firebase-admin/firestore';
import { getStorage } from 'firebase-admin/storage';
import { onRequest } from 'firebase-functions/v2/https';

// Store + site targets are ops-configurable; sensible defaults keep the link
// converting before the custom domain / store listings are finalized.
const PLAY_URL =
  process.env.PANTAS_PLAY_URL ??
  'https://play.google.com/store/apps/details?id=app.pantas';
const APP_STORE_URL =
  process.env.PANTAS_APP_STORE_URL ?? 'https://apps.apple.com/app/pantas';
const SITE_ORIGIN = process.env.PANTAS_WEB_ORIGIN ?? 'https://pantas.app';

const SHARE_ID_PATTERN = /^[0-9a-f]{32}$/;

/**
 * Server-renders the `pantas.app/wrapped/<shareId>` landing page with
 * per-share Open Graph tags, serves the card image, and falls back to a
 * generic marketing page for unknown / revoked links (landing-page spec §4).
 */
export const renderWrappedPage = onRequest(
  { region: 'asia-southeast1' },
  async (req, res) => {
    const ctaHref = storeCtaHref(req.header('user-agent') ?? '');
    const htmlHeaders = { 'Content-Type': 'text/html; charset=utf-8' };
    const { shareId, wantsImage } = parseWrappedPath(req.path);
    if (shareId == null) {
      res.status(200).set(htmlHeaders).send(genericPageHtml(ctaHref));
      return;
    }

    const snapshot = await getFirestore()
      .collection('wrapped_shares')
      .doc(shareId)
      .get();
    const data = snapshot.data();
    if (!snapshot.exists || data == null || data.revoked === true) {
      res.status(200).set(htmlHeaders).send(genericPageHtml(ctaHref));
      return;
    }

    if (wantsImage) {
      try {
        const [bytes] = await getStorage()
          .bucket()
          .file(String(data.storagePath))
          .download();
        res
          .status(200)
          .set({ 'Content-Type': 'image/png', 'Cache-Control': 'public, max-age=300' })
          .send(bytes);
      } catch {
        res.status(404).send('Not found');
      }
      return;
    }

    res
      .status(200)
      .set(htmlHeaders)
      .send(liveCardHtml(shareId, String(data.archetypeId ?? ''), ctaHref));
  },
);

/** Splits `/wrapped/<shareId>[/card.png]` into its parts. */
export function parseWrappedPath(path: string): {
  shareId: string | null;
  wantsImage: boolean;
} {
  const segments = path.split('/').filter((segment) => segment.length > 0);
  if (segments.length < 2 || segments[0] !== 'wrapped') {
    return { shareId: null, wantsImage: false };
  }
  const shareId = segments[1];
  if (!SHARE_ID_PATTERN.test(shareId)) {
    return { shareId: null, wantsImage: false };
  }
  return { shareId, wantsImage: segments[2] === 'card.png' };
}

/** `night_owl_sprinter` -> `Night Owl Sprinter`. */
export function humanizeArchetype(archetypeId: string): string {
  if (!archetypeId) return 'a Pantas reviewer';
  return archetypeId
    .split('_')
    .filter((part) => part.length > 0)
    .map((part) => part[0].toUpperCase() + part.slice(1))
    .join(' ');
}

export function storeCtaHref(userAgent: string): string {
  const ua = userAgent.toLowerCase();
  if (/iphone|ipad|ipod/.test(ua)) return APP_STORE_URL;
  if (/android/.test(ua)) return PLAY_URL;
  return PLAY_URL;
}

function escapeHtml(value: string): string {
  return value
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

function liveCardHtml(
  shareId: string,
  archetypeId: string,
  ctaHref: string,
): string {
  const label = humanizeArchetype(archetypeId);
  const title = `A ${label} on Pantas`;
  const imageUrl = `${SITE_ORIGIN}/wrapped/${shareId}/card.png`;
  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>${escapeHtml(title)}</title>
  <meta property="og:title" content="${escapeHtml(title)}" />
  <meta property="og:image" content="${escapeHtml(imageUrl)}" />
  <meta property="og:type" content="website" />
  <meta name="twitter:card" content="summary_large_image" />
  <meta name="twitter:title" content="${escapeHtml(title)}" />
  <meta name="twitter:image" content="${escapeHtml(imageUrl)}" />
</head>
<body style="margin:0;font-family:system-ui,sans-serif;background:#16213E;color:#fff;text-align:center;">
  <main style="max-width:520px;margin:0 auto;padding:32px 20px;">
    <img src="${escapeHtml(imageUrl)}" alt="Pantas Wrapped card"
         style="width:100%;max-width:360px;border-radius:16px;" />
    <h1 style="font-size:1.5rem;margin:24px 0 8px;">
      Your friend is a ${escapeHtml(label)}. What are you?
    </h1>
    <a href="${escapeHtml(ctaHref)}"
       style="display:inline-block;margin-top:16px;padding:14px 28px;border-radius:999px;background:#533483;color:#fff;text-decoration:none;font-weight:700;">
      Get your Wrapped
    </a>
    <p style="margin-top:32px;opacity:0.6;font-size:0.85rem;">Pantas</p>
  </main>
</body>
</html>`;
}

function genericPageHtml(ctaHref: string): string {
  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Pantas Wrapped</title>
  <meta property="og:title" content="Pantas Wrapped" />
  <meta name="twitter:card" content="summary_large_image" />
</head>
<body style="margin:0;font-family:system-ui,sans-serif;background:#16213E;color:#fff;text-align:center;">
  <main style="max-width:520px;margin:0 auto;padding:48px 20px;">
    <h1 style="font-size:1.6rem;">Pantas Wrapped</h1>
    <p style="opacity:0.8;">See how your exam prep is going. Get your own Wrapped.</p>
    <a href="${escapeHtml(ctaHref)}"
       style="display:inline-block;margin-top:16px;padding:14px 28px;border-radius:999px;background:#533483;color:#fff;text-decoration:none;font-weight:700;">
      Get Pantas
    </a>
  </main>
</body>
</html>`;
}
