import { createHash, randomUUID } from 'node:crypto';
import { readFile, rename, rm, mkdir, writeFile } from 'node:fs/promises';
import { existsSync } from 'node:fs';
import { dirname, isAbsolute, relative, resolve, sep } from 'node:path';
import { parse as parseYaml } from 'yaml';

const STRATEGY_PATH = 'docs/content/illustrations/strategy.tsv';
const REVIEW_PATH = 'docs/content/illustrations/review.json';
const PREVIEW_ROOT_PATH = 'build/lesson_author/illustration_previews';
const DEFAULT_PREVIEW_MANIFEST_PATH = `${PREVIEW_ROOT_PATH}/manifest.json`;
const REFERENCE_MANIFESTS = [
  'docs/content/illustrations/original-code-a.yaml',
  'docs/content/illustrations/original-code-b.yaml',
];
const COMMONS_MANIFESTS = [
  'content/illustrations/sources/open-a.yaml',
  'content/illustrations/sources/open-b.yaml',
];
const REVIEW_BATCHES = new Set(['original-code-a', 'original-code-b']);
const VALID_STATUSES = new Set(['pending', 'approved', 'changes-requested']);
const EXPECTED_COUNTS = Object.freeze({ code: 52, open: 4, founder: 3 });
const writeQueues = new Map();

export class IllustrationReviewError extends Error {
  constructor(message, statusCode = 400) {
    super(message);
    this.name = 'IllustrationReviewError';
    this.statusCode = statusCode;
  }
}

export async function loadIllustrationCatalog({
  repoRoot,
  previewManifestPath = resolve(repoRoot, DEFAULT_PREVIEW_MANIFEST_PATH),
}) {
  const root = resolve(repoRoot);
  const rows = parseStrategyRows(await readFile(resolve(root, STRATEGY_PATH), 'utf8'));
  const reviewRows = rows.filter(
    (row) => REVIEW_BATCHES.has(row.batch) || row.strategy === 'open' || row.strategy === 'founder',
  );
  const counts = {
    code: reviewRows.filter((row) => REVIEW_BATCHES.has(row.batch)).length,
    open: reviewRows.filter((row) => row.strategy === 'open').length,
    founder: reviewRows.filter((row) => row.strategy === 'founder').length,
  };
  for (const [name, expected] of Object.entries(EXPECTED_COUNTS)) {
    if (counts[name] !== expected) {
      throw new IllustrationReviewError(
        `Review strategy expected ${expected} ${name} rows, found ${counts[name]}.`,
        500,
      );
    }
  }

  const references = await loadReferenceManifests(root);
  const commons = await loadCommonsManifests(root);
  const previewEntries = await loadPreviewManifest(root, previewManifestPath);
  const reviewState = await loadReviewState(root);
  const knownKeys = new Set(reviewRows.map((row) => row.key));
  for (const key of Object.keys(reviewState.items)) {
    if (!knownKeys.has(key)) {
      throw new IllustrationReviewError(`Unknown key in review state: ${key}.`, 500);
    }
  }

  const items = [];
  for (const row of reviewRows) {
    let digest = null;
    let previewPaths = null;
    let evidence = null;
    let missingReason = null;

    if (REVIEW_BATCHES.has(row.batch)) {
      const ref = references.get(row.key);
      if (!ref) {
        throw new IllustrationReviewError(
          `Missing factual-reference manifest entry for ${row.key}.`,
          500,
        );
      }
      evidence = { brief: row.description, references: ref.references };
      const preview = previewEntries.get(row.key);
      if (!preview) {
        missingReason = 'Preview has not been rendered.';
      } else {
        const current = await currentCodePreviewDigest(root, preview);
        digest = current.digest;
        previewPaths = {
          light: preview.lightPath,
          dark: preview.darkPath,
        };
        if (!digest) missingReason = 'One or both preview PNGs are missing.';
      }
    } else if (row.strategy === 'open') {
      const source = commons.get(row.key);
      if (!source) {
        throw new IllustrationReviewError(
          `Missing Commons manifest entry for ${row.key}.`,
          500,
        );
      }
      evidence = {
        brief: row.description,
        commons: {
          creator: source.creator,
          sourcePage: source.sourcePage,
          directUrl: source.directUrl,
          license: source.license,
          credit: source.credit,
          target: source.target,
          declaredSha256: source.sha256,
        },
      };
      const target = safeRepoTarget(root, row.target_file);
      if (!existsSync(target)) {
        missingReason = 'Commons PNG is missing.';
      } else {
        digest = await fileSha256(target);
        if (digest !== source.sha256) {
          throw new IllustrationReviewError(
            `Commons digest mismatch for ${row.key}: expected ${source.sha256}, got ${digest}.`,
            500,
          );
        }
      }
    } else {
      evidence = {
        brief: row.description,
        ownership: 'Pantas — all rights reserved',
      };
      const target = safeRepoTarget(root, row.target_file);
      if (!existsSync(target)) {
        missingReason = 'Founder PNG has not been supplied.';
      } else {
        digest = await fileSha256(target);
      }
    }

    const saved = reviewState.items[row.key] ?? null;
    const stale = Boolean(saved && digest && saved.reviewedDigest !== digest);
    let status = 'pending';
    if (!digest) {
      status = 'missing';
    } else if (saved && !stale && VALID_STATUSES.has(saved.status)) {
      status = saved.status;
    }

    items.push({
      key: row.key,
      subject: row.subject,
      topic: row.topic,
      lesson: row.lesson,
      lessonId: `lesson-${row.topic}-${row.lesson}`,
      seq: Number(row.seq),
      strategy: REVIEW_BATCHES.has(row.batch) ? 'code' : row.strategy,
      batch: row.batch,
      targetFile: row.target_file,
      digest,
      status,
      stale,
      missingReason,
      notes: typeof saved?.notes === 'string' ? saved.notes : '',
      reviewedDigest: typeof saved?.reviewedDigest === 'string' ? saved.reviewedDigest : null,
      reviewedAt: typeof saved?.reviewedAt === 'string' ? saved.reviewedAt : null,
      previewPaths,
      evidence,
    });
  }

  items.sort((a, b) => a.key.localeCompare(b.key));
  const summary = {
    total: items.length,
    pending: items.filter((item) => item.status === 'pending').length,
    approved: items.filter((item) => item.status === 'approved').length,
    changesRequested: items.filter((item) => item.status === 'changes-requested').length,
    missing: items.filter((item) => item.status === 'missing').length,
  };
  return { items, summary };
}

export async function saveIllustrationReview(args) {
  const root = resolve(args.repoRoot);
  const previous = writeQueues.get(root) ?? Promise.resolve();
  const next = previous.catch(() => {}).then(() => saveIllustrationReviewUnlocked({ ...args, repoRoot: root }));
  writeQueues.set(root, next);
  try {
    return await next;
  } finally {
    if (writeQueues.get(root) === next) writeQueues.delete(root);
  }
}

async function saveIllustrationReviewUnlocked({
  repoRoot,
  key,
  status,
  notes = '',
  observedDigest,
  beforeRename,
}) {
  if (typeof key !== 'string' || !key.trim()) {
    throw new IllustrationReviewError('Review key is required.');
  }
  if (!VALID_STATUSES.has(status)) {
    throw new IllustrationReviewError(`Invalid review status: ${status}.`);
  }
  if (typeof notes !== 'string') {
    throw new IllustrationReviewError('Review notes must be a string.');
  }
  if (notes.length > 50_000) {
    throw new IllustrationReviewError('Review notes are too long.');
  }

  const catalog = await loadIllustrationCatalog({ repoRoot });
  const item = catalog.items.find((candidate) => candidate.key === key);
  if (!item) throw new IllustrationReviewError(`Unknown illustration key: ${key}.`, 404);
  if (!item.digest) {
    throw new IllustrationReviewError(
      `Illustration ${key} is missing and cannot be reviewed.`,
      409,
    );
  }
  if (typeof observedDigest !== 'string' || observedDigest !== item.digest) {
    throw new IllustrationReviewError(
      `Illustration ${key} changed after it was displayed. Reload before saving review state.`,
      409,
    );
  }

  const state = await loadReviewState(repoRoot);
  const reviewedAt = new Date().toISOString();
  state.items[key] = {
    status,
    notes,
    reviewedDigest: item.digest,
    reviewedAt,
  };
  await writeReviewStateAtomic(repoRoot, state, beforeRename);
  return {
    ...item,
    status,
    notes,
    stale: false,
    reviewedDigest: item.digest,
    reviewedAt,
  };
}

export async function resolveIllustrationPreviewFile({
  repoRoot,
  key,
  theme,
  previewManifestPath = resolve(repoRoot, DEFAULT_PREVIEW_MANIFEST_PATH),
}) {
  if (theme !== 'light' && theme !== 'dark') {
    throw new IllustrationReviewError(`Unknown preview theme: ${theme}.`);
  }
  const catalog = await loadIllustrationCatalog({ repoRoot, previewManifestPath });
  const item = catalog.items.find((candidate) => candidate.key === key);
  if (!item) throw new IllustrationReviewError(`Unknown illustration key: ${key}.`, 404);
  if (!item.digest) {
    throw new IllustrationReviewError(`Illustration ${key} is missing.`, 404);
  }
  if (item.strategy === 'code') {
    const manifestRoot = dirname(resolve(previewManifestPath));
    return safePreviewPath(resolve(repoRoot), manifestRoot, item.previewPaths[theme]);
  }
  return safeRepoTarget(resolve(repoRoot), item.targetFile);
}

export function combinedPreviewDigest(lightBytes, darkBytes) {
  const lightHash = sha256(lightBytes);
  const darkHash = sha256(darkBytes);
  return sha256(Buffer.from(`${lightHash}:${darkHash}`, 'utf8'));
}

export function parseStrategyRows(raw) {
  if (typeof raw !== 'string' || !raw.trim()) {
    throw new IllustrationReviewError('strategy.tsv is empty.', 500);
  }
  const lines = raw.trimEnd().split(/\r?\n/);
  const header = lines.shift().split('\t');
  const required = ['subject', 'topic', 'lesson', 'seq', 'target_file', 'description', 'strategy', 'batch'];
  for (const name of required) {
    if (!header.includes(name)) {
      throw new IllustrationReviewError(`strategy.tsv is missing column ${name}.`, 500);
    }
  }
  const rows = [];
  const keys = new Set();
  for (const line of lines) {
    if (!line.trim()) continue;
    const columns = line.split('\t');
    if (columns.length !== header.length) {
      throw new IllustrationReviewError('Malformed strategy.tsv row.', 500);
    }
    const row = Object.fromEntries(header.map((name, index) => [name, columns[index]]));
    const seq = Number(row.seq);
    if (!Number.isInteger(seq) || seq < 1) {
      throw new IllustrationReviewError(`Invalid illustration sequence: ${row.seq}.`, 500);
    }
    row.key = `${row.subject}/${row.topic}/${row.lesson}#${seq}`;
    if (keys.has(row.key)) {
      throw new IllustrationReviewError(`Duplicate illustration key: ${row.key}.`, 500);
    }
    keys.add(row.key);
    rows.push(row);
  }
  return rows;
}

async function loadReferenceManifests(root) {
  const result = new Map();
  for (const path of REFERENCE_MANIFESTS) {
    const parsed = parseYaml(await readFile(resolve(root, path), 'utf8'));
    if (!parsed || parsed.version !== 1 || !Array.isArray(parsed.figures)) {
      throw new IllustrationReviewError(`Invalid reference manifest: ${path}.`, 500);
    }
    for (const figure of parsed.figures) {
      if (!figure || typeof figure.key !== 'string' || !Array.isArray(figure.references)) {
        throw new IllustrationReviewError(`Invalid reference entry in ${path}.`, 500);
      }
      if (result.has(figure.key)) {
        throw new IllustrationReviewError(`Duplicate reference key: ${figure.key}.`, 500);
      }
      result.set(figure.key, figure);
    }
  }
  return result;
}

async function loadCommonsManifests(root) {
  const result = new Map();
  for (const path of COMMONS_MANIFESTS) {
    const parsed = parseYaml(await readFile(resolve(root, path), 'utf8'));
    if (!parsed || parsed.version !== 1 || !Array.isArray(parsed.assets)) {
      throw new IllustrationReviewError(`Invalid Commons manifest: ${path}.`, 500);
    }
    for (const asset of parsed.assets) {
      const required = ['key', 'sourcePage', 'directUrl', 'license', 'creator', 'credit', 'target', 'sha256'];
      if (!asset || required.some((field) => typeof asset[field] !== 'string' || !asset[field])) {
        throw new IllustrationReviewError(`Invalid Commons entry in ${path}.`, 500);
      }
      if (result.has(asset.key)) {
        throw new IllustrationReviewError(`Duplicate Commons key: ${asset.key}.`, 500);
      }
      result.set(asset.key, asset);
    }
  }
  return result;
}

async function loadPreviewManifest(root, manifestPath) {
  const previewRoot = resolve(root, PREVIEW_ROOT_PATH);
  const resolvedManifest = resolve(manifestPath);
  if (!isWithin(previewRoot, resolvedManifest) || resolvedManifest === previewRoot) {
    throw new IllustrationReviewError('Preview manifest must be inside the build preview root.', 500);
  }
  if (!existsSync(resolvedManifest)) return new Map();

  let parsed;
  try {
    parsed = JSON.parse(await readFile(resolvedManifest, 'utf8'));
  } catch (error) {
    throw new IllustrationReviewError(`Invalid preview manifest: ${error.message}`, 500);
  }
  if (!parsed || parsed.version !== 1 || !Array.isArray(parsed.items)) {
    throw new IllustrationReviewError('Invalid preview manifest shape.', 500);
  }
  const result = new Map();
  for (const entry of parsed.items) {
    if (
      !entry ||
      typeof entry.key !== 'string' ||
      typeof entry.lightPath !== 'string' ||
      typeof entry.darkPath !== 'string' ||
      typeof entry.digest !== 'string'
    ) {
      throw new IllustrationReviewError('Invalid preview manifest entry.', 500);
    }
    safePreviewPath(root, dirname(resolvedManifest), entry.lightPath);
    safePreviewPath(root, dirname(resolvedManifest), entry.darkPath);
    if (result.has(entry.key)) {
      throw new IllustrationReviewError(`Duplicate preview key: ${entry.key}.`, 500);
    }
    result.set(entry.key, entry);
  }
  return result;
}

async function currentCodePreviewDigest(root, preview) {
  const manifestRoot = resolve(root, PREVIEW_ROOT_PATH);
  const light = safePreviewPath(root, manifestRoot, preview.lightPath);
  const dark = safePreviewPath(root, manifestRoot, preview.darkPath);
  if (!existsSync(light) || !existsSync(dark)) return { digest: null };
  const [lightBytes, darkBytes] = await Promise.all([readFile(light), readFile(dark)]);
  return { digest: combinedPreviewDigest(lightBytes, darkBytes) };
}

async function loadReviewState(root) {
  const path = resolve(root, REVIEW_PATH);
  if (!existsSync(path)) return { version: 1, items: {} };
  let parsed;
  try {
    parsed = JSON.parse(await readFile(path, 'utf8'));
  } catch (error) {
    throw new IllustrationReviewError(`Invalid review.json: ${error.message}`, 500);
  }
  if (!parsed || parsed.version !== 1 || !parsed.items || Array.isArray(parsed.items) || typeof parsed.items !== 'object') {
    throw new IllustrationReviewError('Invalid review.json shape.', 500);
  }
  for (const [key, item] of Object.entries(parsed.items)) {
    if (
      !item ||
      typeof item !== 'object' ||
      !VALID_STATUSES.has(item.status) ||
      typeof item.notes !== 'string' ||
      typeof item.reviewedDigest !== 'string' ||
      typeof item.reviewedAt !== 'string'
    ) {
      throw new IllustrationReviewError(`Invalid review state for ${key}.`, 500);
    }
  }
  return parsed;
}

async function writeReviewStateAtomic(root, state, beforeRename) {
  const path = resolve(root, REVIEW_PATH);
  await mkdir(dirname(path), { recursive: true });
  const temporary = `${path}.tmp-${process.pid}-${randomUUID()}`;
  try {
    const sortedItems = Object.fromEntries(
      Object.entries(state.items).sort(([left], [right]) => left.localeCompare(right)),
    );
    await writeFile(
      temporary,
      `${JSON.stringify({ version: 1, items: sortedItems }, null, 2)}\n`,
      'utf8',
    );
    if (beforeRename) await beforeRename(temporary, path);
    await rename(temporary, path);
  } catch (error) {
    await rm(temporary, { force: true }).catch(() => {});
    throw error;
  }
}

function safeRepoTarget(root, target) {
  if (typeof target !== 'string' || !target || isAbsolute(target)) {
    throw new IllustrationReviewError('Invalid illustration target path.', 500);
  }
  const segments = target.split(/[\\/]/);
  if (segments.includes('..')) {
    throw new IllustrationReviewError('Invalid illustration target path.', 500);
  }
  const resolved = resolve(root, target);
  if (!isWithin(root, resolved)) {
    throw new IllustrationReviewError('Illustration target escapes the repository.', 500);
  }
  return resolved;
}

function safePreviewPath(root, manifestRoot, manifestPath) {
  if (typeof manifestPath !== 'string' || !manifestPath || isAbsolute(manifestPath)) {
    throw new IllustrationReviewError('Invalid preview path.', 500);
  }
  const segments = manifestPath.split(/[\\/]/);
  if (segments.includes('..')) {
    throw new IllustrationReviewError('Preview traversal is not allowed.', 500);
  }
  const previewRoot = resolve(root, PREVIEW_ROOT_PATH);
  const resolved = resolve(manifestRoot, manifestPath);
  if (!isWithin(previewRoot, resolved)) {
    throw new IllustrationReviewError('Preview path escapes the build preview root.', 500);
  }
  return resolved;
}

function isWithin(root, candidate) {
  const rel = relative(root, candidate);
  return rel === '' || (!rel.startsWith(`..${sep}`) && rel !== '..' && !isAbsolute(rel));
}

async function fileSha256(path) {
  return sha256(await readFile(path));
}

function sha256(bytes) {
  return createHash('sha256').update(bytes).digest('hex');
}
