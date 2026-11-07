// Run with: node --test test/web/preconnect.test.mjs
import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';

const html = readFileSync(new URL('../../web/index.html', import.meta.url), 'utf8');
const head = html.slice(html.indexOf('<head>'), html.indexOf('</head>'));
const links = [...head.matchAll(/<link\b[^>]*>/g)].map((match) => match[0]);

test('the page preconnects to the eight startup origins with CORS where needed', () => {
  const origins = [
    ['https://www.gstatic.com', false],
    ['https://asia-southeast1-pantas-prod.cloudfunctions.net', true],
    ['https://content-firebaseappcheck.googleapis.com', true],
    ['https://securetoken.googleapis.com', true],
    ['https://identitytoolkit.googleapis.com', true],
    ['https://firebaseremoteconfig.googleapis.com', true],
    ['https://firebaseinstallations.googleapis.com', true],
    ['https://www.google.com', false],
  ];
  const hints = links.filter((link) => /\brel="preconnect"/.test(link));
  assert.equal(hints.length, origins.length);
  for (const [origin, cors] of origins) {
    const hint = hints.find((link) => link.includes(`href="${origin}"`));
    assert.ok(hint, `preconnect for ${origin}`);
    assert.equal(/\bcrossorigin(?:\s|=|>)/.test(hint), cors, origin);
    assert.ok(head.indexOf(hint) < head.indexOf('<script'), origin);
  }
});

test('the page does not preload main.dart.js or CanvasKit', () => {
  const preloads = links.filter((link) => /\brel="(?:modulepreload|preload)"/.test(link));
  for (const link of preloads) {
    assert.doesNotMatch(link, /main\.dart\.js|canvaskit/i);
  }
});
