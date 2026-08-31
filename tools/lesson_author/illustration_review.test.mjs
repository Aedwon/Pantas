import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { mkdtemp, mkdir, readFile, rm, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import test from 'node:test';

import {
  IllustrationReviewError,
  combinedPreviewDigest,
  loadIllustrationCatalog,
  saveIllustrationReview,
} from './illustration_review.mjs';

const strategyHeader = [
  'subject',
  'topic',
  'lesson',
  'seq',
  'target_file',
  'description',
  'strategy',
  'batch',
].join('\t');

test('catalog contains exactly 59 review items with missing founder precedence', async (t) => {
  const fixture = await createFixture(t);
  const catalog = await loadIllustrationCatalog({ repoRoot: fixture.root });

  assert.deepEqual(catalog.summary, {
    total: 59,
    pending: 56,
    approved: 0,
    changesRequested: 0,
    missing: 3,
  });
  assert.equal(catalog.items.filter((item) => item.strategy === 'code').length, 52);
  assert.equal(catalog.items.filter((item) => item.strategy === 'open').length, 4);
  assert.equal(catalog.items.filter((item) => item.strategy === 'founder').length, 3);
  assert.equal(catalog.items.find((item) => item.key === fixture.codeKeys[0]).evidence.references[0].publisher, 'Fixture');
  assert.equal(catalog.items.find((item) => item.key === fixture.openKeys[0]).evidence.commons.creator, 'Fixture Creator 0');
});

test('approve and changes-requested writes are digest-bound and preserve notes', async (t) => {
  const fixture = await createFixture(t);
  const catalog = await loadIllustrationCatalog({ repoRoot: fixture.root });
  const item = catalog.items.find((candidate) => candidate.key === fixture.codeKeys[0]);

  const approved = await saveIllustrationReview({
    repoRoot: fixture.root,
    key: item.key,
    status: 'approved',
    notes: 'Looks correct.',
    observedDigest: item.digest,
  });
  assert.equal(approved.status, 'approved');
  assert.equal(approved.notes, 'Looks correct.');

  const changed = await saveIllustrationReview({
    repoRoot: fixture.root,
    key: item.key,
    status: 'changes-requested',
    notes: 'Move the label.',
    observedDigest: item.digest,
  });
  assert.equal(changed.status, 'changes-requested');

  const reloaded = await loadIllustrationCatalog({ repoRoot: fixture.root });
  const saved = reloaded.items.find((candidate) => candidate.key === item.key);
  assert.equal(saved.status, 'changes-requested');
  assert.equal(saved.notes, 'Move the label.');
});

test('unknown keys, invalid status, digest mismatch, and missing files are rejected', async (t) => {
  const fixture = await createFixture(t);
  const catalog = await loadIllustrationCatalog({ repoRoot: fixture.root });
  const code = catalog.items.find((candidate) => candidate.key === fixture.codeKeys[0]);
  const founder = catalog.items.find((candidate) => candidate.key === fixture.founderKeys[0]);

  await assert.rejects(
    saveIllustrationReview({
      repoRoot: fixture.root,
      key: 'unknown/topic/lesson#1',
      status: 'approved',
      notes: '',
      observedDigest: code.digest,
    }),
    (error) => error instanceof IllustrationReviewError && error.statusCode === 404,
  );
  await assert.rejects(
    saveIllustrationReview({
      repoRoot: fixture.root,
      key: code.key,
      status: 'maybe',
      notes: '',
      observedDigest: code.digest,
    }),
    (error) => error instanceof IllustrationReviewError && error.statusCode === 400,
  );
  await assert.rejects(
    saveIllustrationReview({
      repoRoot: fixture.root,
      key: code.key,
      status: 'approved',
      notes: '',
      observedDigest: '0'.repeat(64),
    }),
    (error) => error instanceof IllustrationReviewError && error.statusCode === 409,
  );
  await assert.rejects(
    saveIllustrationReview({
      repoRoot: fixture.root,
      key: founder.key,
      status: 'approved',
      notes: '',
      observedDigest: null,
    }),
    (error) => error instanceof IllustrationReviewError && error.statusCode === 409,
  );
});

test('changed preview bytes make an existing approval stale and pending', async (t) => {
  const fixture = await createFixture(t);
  let catalog = await loadIllustrationCatalog({ repoRoot: fixture.root });
  const item = catalog.items.find((candidate) => candidate.key === fixture.codeKeys[0]);
  await saveIllustrationReview({
    repoRoot: fixture.root,
    key: item.key,
    status: 'approved',
    notes: 'Keep this note.',
    observedDigest: item.digest,
  });

  await writeFile(fixture.previewFiles.get(item.key).light, Buffer.from('changed-light-preview'));
  catalog = await loadIllustrationCatalog({ repoRoot: fixture.root });
  const stale = catalog.items.find((candidate) => candidate.key === item.key);
  assert.equal(stale.status, 'pending');
  assert.equal(stale.stale, true);
  assert.equal(stale.notes, 'Keep this note.');
  assert.notEqual(stale.digest, item.digest);
});

test('atomic write failure leaves the previous review file untouched', async (t) => {
  const fixture = await createFixture(t);
  const catalog = await loadIllustrationCatalog({ repoRoot: fixture.root });
  const item = catalog.items.find((candidate) => candidate.key === fixture.codeKeys[0]);
  await saveIllustrationReview({
    repoRoot: fixture.root,
    key: item.key,
    status: 'approved',
    notes: 'Original',
    observedDigest: item.digest,
  });
  const before = await readFile(fixture.reviewPath, 'utf8');

  await assert.rejects(
    saveIllustrationReview({
      repoRoot: fixture.root,
      key: item.key,
      status: 'changes-requested',
      notes: 'Should not persist',
      observedDigest: item.digest,
      beforeRename: async () => {
        throw new Error('injected rename failure');
      },
    }),
    /injected rename failure/,
  );

  assert.equal(await readFile(fixture.reviewPath, 'utf8'), before);
});

test('concurrent review writes preserve both records', async (t) => {
  const fixture = await createFixture(t);
  const catalog = await loadIllustrationCatalog({ repoRoot: fixture.root });
  const first = catalog.items.find((candidate) => candidate.key === fixture.codeKeys[0]);
  const second = catalog.items.find((candidate) => candidate.key === fixture.codeKeys[1]);

  await Promise.all([
    saveIllustrationReview({
      repoRoot: fixture.root,
      key: first.key,
      status: 'approved',
      notes: 'First',
      observedDigest: first.digest,
    }),
    saveIllustrationReview({
      repoRoot: fixture.root,
      key: second.key,
      status: 'changes-requested',
      notes: 'Second',
      observedDigest: second.digest,
    }),
  ]);

  const state = JSON.parse(await readFile(fixture.reviewPath, 'utf8'));
  assert.equal(state.items[first.key].status, 'approved');
  assert.equal(state.items[second.key].status, 'changes-requested');
});

test('preview manifest traversal and absolute paths are rejected', async (t) => {
  const fixture = await createFixture(t);
  const manifest = JSON.parse(await readFile(fixture.manifestPath, 'utf8'));
  manifest.items[0].lightPath = '../escape.png';
  await writeFile(fixture.manifestPath, JSON.stringify(manifest));
  await assert.rejects(
    loadIllustrationCatalog({ repoRoot: fixture.root }),
    /Preview traversal is not allowed/,
  );

  await createFixtureFiles(fixture);
  const absoluteManifest = JSON.parse(await readFile(fixture.manifestPath, 'utf8'));
  absoluteManifest.items[0].darkPath = join(fixture.root, 'outside.png');
  await writeFile(fixture.manifestPath, JSON.stringify(absoluteManifest));
  await assert.rejects(
    loadIllustrationCatalog({ repoRoot: fixture.root }),
    /Invalid preview path/,
  );
});

test('malformed review JSON fails closed', async (t) => {
  const fixture = await createFixture(t);
  await writeFile(fixture.reviewPath, '{not json');
  await assert.rejects(
    loadIllustrationCatalog({ repoRoot: fixture.root }),
    /Invalid review.json/,
  );
});

async function createFixture(t) {
  const root = await mkdtemp(join(tmpdir(), 'pantas-illustration-review-'));
  t.after(() => rm(root, { recursive: true, force: true }));
  const fixture = {
    root,
    codeKeys: Array.from({ length: 52 }, (_, index) => `science/review/code-${index}#1`),
    openKeys: Array.from({ length: 4 }, (_, index) => `science/review/open-${index}#1`),
    founderKeys: Array.from({ length: 3 }, (_, index) => `science/review/founder-${index}#1`),
    previewFiles: new Map(),
    manifestPath: join(root, 'build', 'lesson_author', 'illustration_previews', 'manifest.json'),
    reviewPath: join(root, 'docs', 'content', 'illustrations', 'review.json'),
  };
  await createFixtureFiles(fixture);
  return fixture;
}

async function createFixtureFiles(fixture) {
  const { root, codeKeys, openKeys, founderKeys } = fixture;
  const strategyRows = [];
  for (let index = 0; index < codeKeys.length; index += 1) {
    strategyRows.push(
      strategyRow({
        lesson: `code-${index}`,
        target: `content/illustrations/code-${index}.png`,
        description: `Code brief ${index}`,
        strategy: 'code',
        batch: index < 27 ? 'original-code-a' : 'original-code-b',
      }),
    );
  }
  for (let index = 0; index < openKeys.length; index += 1) {
    strategyRows.push(
      strategyRow({
        lesson: `open-${index}`,
        target: `content/illustrations/open-${index}.png`,
        description: `Open brief ${index}`,
        strategy: 'open',
        batch: index < 2 ? 'open-a' : 'open-b',
      }),
    );
  }
  for (let index = 0; index < founderKeys.length; index += 1) {
    strategyRows.push(
      strategyRow({
        lesson: `founder-${index}`,
        target: `content/illustrations/founder-${index}.png`,
        description: `Founder brief ${index}`,
        strategy: 'founder',
        batch: 'founder',
      }),
    );
  }
  await write(root, 'docs/content/illustrations/strategy.tsv', `${strategyHeader}\n${strategyRows.join('\n')}\n`);

  const refs = codeKeys.map((key) => ({
    key,
    references: [{ title: `Reference for ${key}`, publisher: 'Fixture', url: 'https://example.com/reference' }],
  }));
  await write(root, 'docs/content/illustrations/original-code-a.yaml', JSON.stringify({ version: 1, figures: refs.slice(0, 27) }));
  await write(root, 'docs/content/illustrations/original-code-b.yaml', JSON.stringify({ version: 1, figures: refs.slice(27) }));

  const commons = [];
  for (let index = 0; index < openKeys.length; index += 1) {
    const target = `content/illustrations/open-${index}.png`;
    const bytes = Buffer.from(`open-${index}`);
    await write(root, target, bytes);
    commons.push({
      key: openKeys[index],
      sourcePage: `https://commons.wikimedia.org/wiki/File:Fixture_${index}.png`,
      directUrl: `https://upload.wikimedia.org/fixture-${index}.png`,
      license: 'CC BY 4.0',
      creator: `Fixture Creator ${index}`,
      credit: `Fixture Creator ${index} / CC BY 4.0`,
      target,
      sha256: hash(bytes),
    });
  }
  await write(root, 'content/illustrations/sources/open-a.yaml', JSON.stringify({ version: 1, assets: commons.slice(0, 2) }));
  await write(root, 'content/illustrations/sources/open-b.yaml', JSON.stringify({ version: 1, assets: commons.slice(2) }));

  const previewItems = [];
  fixture.previewFiles.clear();
  for (let index = 0; index < codeKeys.length; index += 1) {
    const lightPath = `light/code-${index}.png`;
    const darkPath = `dark/code-${index}.png`;
    const lightBytes = Buffer.from(`light-${index}`);
    const darkBytes = Buffer.from(`dark-${index}`);
    const lightFile = join(root, 'build', 'lesson_author', 'illustration_previews', lightPath);
    const darkFile = join(root, 'build', 'lesson_author', 'illustration_previews', darkPath);
    await write(root, `build/lesson_author/illustration_previews/${lightPath}`, lightBytes);
    await write(root, `build/lesson_author/illustration_previews/${darkPath}`, darkBytes);
    fixture.previewFiles.set(codeKeys[index], { light: lightFile, dark: darkFile });
    previewItems.push({
      key: codeKeys[index],
      lightPath,
      darkPath,
      digest: combinedPreviewDigest(lightBytes, darkBytes),
      width: 390,
      height: 200,
    });
  }
  await write(root, 'build/lesson_author/illustration_previews/manifest.json', JSON.stringify({ version: 1, items: previewItems }));
  await write(root, 'docs/content/illustrations/review.json', '{"version":1,"items":{}}\n');
}

function strategyRow({ lesson, target, description, strategy, batch }) {
  return ['science', 'review', lesson, '1', target, description, strategy, batch].join('\t');
}

async function write(root, relativePath, contents) {
  const path = join(root, relativePath);
  await mkdir(dirname(path), { recursive: true });
  await writeFile(path, contents);
}

function hash(bytes) {
  return createHash('sha256').update(bytes).digest('hex');
}
