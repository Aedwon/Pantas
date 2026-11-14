// Cloudflare Worker for the Pantas web app (security fixes step 5, S-01). Plan:
// docs/superpowers/plans/security-audit/2026-11-14-cloudflare-static-files-plan.md
//
// Static files are served by Workers static assets and never reach this script, except /__/*
// (wrangler config: run_worker_first). Those are Firebase's sign-in pages and config, forwarded to
// the project's firebaseapp.com host, Firebase's documented proxy setup for a custom auth domain.

const PREFIX = '/__/';

/** Exported for tests; `forward` is fetch. */
export async function handle(request, env, forward = fetch) {
  const url = new URL(request.url);
  if (!url.pathname.startsWith(PREFIX)) return env.ASSETS.fetch(request);
  const target = new URL(url.pathname + url.search, env.FIREBASE_ORIGIN);
  const headers = new Headers(request.headers);
  headers.delete('host');
  const hasBody = request.method !== 'GET' && request.method !== 'HEAD';
  return forward(target, {
    method: request.method,
    headers,
    body: hasBody ? request.body : undefined,
    redirect: 'manual',
  });
}

export default {fetch: (request, env) => handle(request, env)};
