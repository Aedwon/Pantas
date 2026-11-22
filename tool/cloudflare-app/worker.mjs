// Cloudflare Worker for the Pantas web app (security fixes step 5, S-01). Plan:
// docs/superpowers/plans/security-audit/2026-11-14-cloudflare-static-files-plan.md
//
// Static files are served by Workers static assets and never reach this script, except /__/*
// (wrangler config: run_worker_first). Those are Firebase's sign-in pages and config, forwarded to
// the project's firebaseapp.com host, Firebase's documented proxy setup for a custom auth domain.

const PREFIX = '/__/';
// CSP violation reports from the report-only policy in headers.<env> (M4 security pass). Logged to
// Workers Logs (Free: 200,000 events a day, 3-day retention) and never forwarded.
const CSP_REPORT = '/__/csp-report';
const CSP_REPORT_MAX_BYTES = 8192;

/** Origin and path only: query strings can carry tokens. */
const bare = (value) => {
  if (typeof value !== 'string' || !value) return null;
  try { const u = new URL(value); return u.origin === 'null' ? value.split(/[?#]/)[0] : u.origin + u.pathname; }
  catch { return value.split(/[?#]/)[0].slice(0, 200); }
};
const pagePath = (value) => { try { return new URL(value).pathname; } catch { return null; } };

async function cspReport(request) {
  if (request.method !== 'POST') return new Response(null, {status: 405});
  const text = await request.text();
  if (text.length > CSP_REPORT_MAX_BYTES) return new Response(null, {status: 413});
  let parsed;
  try { parsed = JSON.parse(text); } catch { return new Response(null, {status: 400}); }
  // report-uri sends {"csp-report": {...}}; the Reporting API sends [{type, body: {...}}].
  const reports = Array.isArray(parsed)
    ? parsed.filter(r => r?.type === 'csp-violation').map(r => r.body ?? {}).map(b => ({
      directive: b.effectiveDirective, blocked: b.blockedURL, page: b.documentURL, source: b.sourceFile, line: b.lineNumber}))
    : [parsed?.['csp-report'] ?? {}].map(r => ({directive: r['effective-directive'] ?? r['violated-directive'],
      blocked: r['blocked-uri'], page: r['document-uri'], source: r['source-file'], line: r['line-number']}));
  for (const r of reports.slice(0, 10)) {
    console.log(JSON.stringify({kind: 'csp_report', directive: String(r.directive ?? '').slice(0, 64), blocked: bare(r.blocked),
      page: pagePath(r.page), source: bare(r.source), line: Number.isInteger(r.line) ? r.line : null}));
  }
  return new Response(null, {status: 204});
}

/** Exported for tests; `forward` is fetch. */
export async function handle(request, env, forward = fetch) {
  const url = new URL(request.url);
  if (!url.pathname.startsWith(PREFIX)) return env.ASSETS.fetch(request);
  if (url.pathname === CSP_REPORT) return cspReport(request);
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
