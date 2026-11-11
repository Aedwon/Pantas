import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import test, {before, after} from 'node:test';
import {initializeTestEnvironment, assertFails, assertSucceeds} from '@firebase/rules-unit-testing';
import {ref, uploadBytes, getBytes, deleteObject} from 'firebase/storage';

assert.ok(process.env.FIREBASE_STORAGE_EMULATOR_HOST);
const OWNER = 'l1-storage-owner';
const OTHER = 'l1-storage-other';
const ID = 'e'.repeat(32);
const png = {contentType: 'image/png'};
let env;
const named = uid => env.authenticatedContext(uid, {firebase: {sign_in_provider: 'google.com'}}).storage();
const anon = uid => env.authenticatedContext(uid, {firebase: {sign_in_provider: 'anonymous'}}).storage();
const signedOut = () => env.unauthenticatedContext().storage();
const bytes = n => new Uint8Array(n).fill(7);

before(async () => {
  env = await initializeTestEnvironment({projectId: 'demo-pantas-test',
    storage: {rules: readFileSync(new URL('../../storage.rules', import.meta.url), 'utf8')}});
  await env.withSecurityRulesDisabled(async context => {
    const s = context.storage();
    await uploadBytes(ref(s, `wrapped/${OWNER}/${'f'.repeat(32)}.png`), bytes(10), png);
    await uploadBytes(ref(s, `exports/${OWNER}/data.zip`), bytes(10), {contentType: 'application/zip'});
    await uploadBytes(ref(s, 'private/secret.bin'), bytes(10));
  });
});
after(async () => env.cleanup());

test('wrapped: owner, named or anonymous, uploads a PNG card', async () => {
  await assertSucceeds(uploadBytes(ref(named(OWNER), `wrapped/${OWNER}/${ID}.png`), bytes(1000), png));
  await assertSucceeds(uploadBytes(ref(anon(OWNER), `wrapped/${OWNER}/${'1'.repeat(32)}.png`), bytes(1000), png));
});

test('wrapped: other account and signed-out client cannot upload, replace or delete', async () => {
  const path = `wrapped/${OWNER}/${ID}.png`;
  await assertFails(uploadBytes(ref(named(OTHER), path), bytes(1000), png));
  await assertFails(uploadBytes(ref(signedOut(), path), bytes(1000), png));
  await assertFails(deleteObject(ref(named(OTHER), path)));
  await assertFails(deleteObject(ref(signedOut(), path)));
});

test('wrapped: invalid shape is denied (type, name, empty, oversize)', async () => {
  const db = named(OWNER);
  await assertFails(uploadBytes(ref(db, `wrapped/${OWNER}/${'2'.repeat(32)}.png`), bytes(1000), {contentType: 'text/html'}));
  await assertFails(uploadBytes(ref(db, `wrapped/${OWNER}/${'2'.repeat(32)}.png`), bytes(1000), {contentType: 'application/octet-stream'}));
  await assertFails(uploadBytes(ref(db, `wrapped/${OWNER}/card.png`), bytes(1000), png));
  await assertFails(uploadBytes(ref(db, `wrapped/${OWNER}/${'2'.repeat(32)}.html`), bytes(1000), png));
  await assertFails(uploadBytes(ref(db, `wrapped/${OWNER}/${'G'.repeat(32)}.png`), bytes(1000), png));
  await assertFails(uploadBytes(ref(db, `wrapped/${OWNER}/${'2'.repeat(32)}.png`), bytes(0), png));
  await assertFails(uploadBytes(ref(db, `wrapped/${OWNER}/${'2'.repeat(32)}.png`), bytes(5 * 1024 * 1024 + 1), png));
  await assertSucceeds(uploadBytes(ref(db, `wrapped/${OWNER}/${'3'.repeat(32)}.png`), bytes(5 * 1024 * 1024), png));
});

test('wrapped: owner deletes their card; no client reads any card', async () => {
  const path = `wrapped/${OWNER}/${'f'.repeat(32)}.png`;
  await assertFails(getBytes(ref(named(OWNER), path)));
  await assertFails(getBytes(ref(named(OTHER), path)));
  await assertFails(getBytes(ref(signedOut(), path)));
  await assertSucceeds(deleteObject(ref(named(OWNER), path)));
});

test('server-only buckets paths deny every client: exports and unlisted paths', async () => {
  for (const s of [named(OWNER), anon(OWNER), named(OTHER), signedOut()]) {
    await assertFails(getBytes(ref(s, `exports/${OWNER}/data.zip`)));
    await assertFails(uploadBytes(ref(s, `exports/${OWNER}/data.zip`), bytes(10), {contentType: 'application/zip'}));
    await assertFails(deleteObject(ref(s, `exports/${OWNER}/data.zip`)));
    await assertFails(getBytes(ref(s, 'private/secret.bin')));
    await assertFails(uploadBytes(ref(s, 'private/new.bin'), bytes(10)));
    await assertFails(uploadBytes(ref(s, `${OWNER}/profile.png`), bytes(10), png));
  }
});
