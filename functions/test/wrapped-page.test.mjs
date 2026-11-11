import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import test from 'node:test';

const render = () =>
  readFileSync(new URL('../src/renderWrappedPage.ts', import.meta.url), 'utf8');
const indexSource = () =>
  readFileSync(new URL('../src/index.ts', import.meta.url), 'utf8');
const deleteAccount = () =>
  readFileSync(new URL('../src/deleteAccount.ts', import.meta.url), 'utf8');

test('renderWrappedPage is an asia-southeast1 HTTP function', () => {
  const source = render();
  assert.match(source, /onRequest/);
  assert.match(source, /region: 'asia-southeast1'/);
});

test('renderWrappedPage reads wrapped_shares and honours revocation', () => {
  const source = render();
  assert.match(source, /collection\('wrapped_shares'\)/);
  assert.match(source, /data\.revoked === true/);
});

test('renderWrappedPage emits per-share Open Graph and Twitter tags', () => {
  const source = render();
  assert.match(source, /property="og:image"/);
  assert.match(source, /property="og:title"/);
  assert.match(source, /name="twitter:card" content="summary_large_image"/);
});

test('renderWrappedPage serves the card image with a cache header', () => {
  const source = render();
  assert.match(source, /image\/png/);
  assert.match(source, /Cache-Control'?: 'public, max-age=300'/);
});

test('renderWrappedPage falls back to a generic page (200) for bad links', () => {
  const source = render();
  assert.match(source, /genericPageHtml/);
  // Fallback must convert, not 404 the link.
  assert.match(source, /status\(200\)/);
});

test('renderWrappedPage is exported from index', () => {
  assert.match(indexSource(), /export \{ renderWrappedPage \}/);
});

test('deleteAccount purges hosted cards and their storage objects', () => {
  const source = deleteAccount();
  assert.match(source, /collection\('wrapped_shares'\)/);
  assert.match(source, /ownerUid', '==', uid/);
  assert.match(source, /deleteFiles\(\{ prefix: `wrapped\/\$\{uid\}\//);
});
