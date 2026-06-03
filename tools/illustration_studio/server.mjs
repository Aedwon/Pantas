// Local illustration studio server. Cycles through ILLUSTRATION placeholders,
// watches ~/Downloads for freshly exported images, and "connects" a download
// to its slot: convert to PNG + shrink to 1600px (via macOS sips), rename to
// the worklist filename, move into content/illustrations/, delete the
// original. No dependencies.
import { createServer } from 'node:http';
import {
  readFile, writeFile, readdir, stat, mkdir, unlink, realpath,
} from 'node:fs/promises';
import { existsSync } from 'node:fs';
import { spawn } from 'node:child_process';
import { dirname, join, resolve, extname, basename, sep } from 'node:path';
import { fileURLToPath } from 'node:url';
import { homedir, tmpdir } from 'node:os';

const PORT = Number(process.env.ILLUS_PORT ?? 4322);
const toolDir = dirname(fileURLToPath(import.meta.url));
const repoRoot = resolve(toolDir, '..', '..');
const illusRoot = join(repoRoot, 'content', 'illustrations');
const worklistPath = join(repoRoot, 'docs', 'content', 'illustrations', 'worklist.tsv');
const downloadsDir = process.env.ILLUS_DOWNLOADS_DIR ?? join(homedir(), 'Downloads');

const IMAGE_EXTS = new Set(['.png', '.jpg', '.jpeg', '.webp', '.gif', '.heic', '.tiff', '.bmp']);
const MAX_WIDTH = 1600;

// Symlink-proof containment check: true when `path` is `root` or inside it.
async function isWithin(path, root) {
  let real;
  try {
    real = await realpath(path);
  } catch {
    return false;
  }
  let realRoot;
  try {
    realRoot = await realpath(root);
  } catch {
    return false;
  }
  return real === realRoot || real.startsWith(realRoot + sep);
}

// --- Worklist ---
// The Python extractor (tools/audit/list_illustrations.py) is the single
// owner of marker -> filename logic; this server only reads its TSV output.

function runPython() {
  return new Promise((resolvePromise, reject) => {
    const py = spawn('python3', [join(repoRoot, 'tools', 'audit', 'list_illustrations.py')], {
      stdio: ['ignore', 'pipe', 'pipe'],
    });
    let out = '';
    py.stdout.on('data', (d) => (out += d));
    py.stderr.on('data', (d) => (out += d));
    py.on('close', (code) =>
      code === 0 ? resolvePromise(out) : reject(new Error(`list_illustrations.py failed:\n${out}`)),
    );
  });
}

let items = [];
async function loadWorklist() {
  const raw = await readFile(worklistPath, 'utf8');
  const lines = raw.trim().split('\n');
  const header = lines.shift().split('\t');
  const col = Object.fromEntries(header.map((h, i) => [h, i]));
  items = lines.map((line, index) => {
    const f = line.split('\t');
    return {
      index,
      subject: f[col.subject],
      topic: f[col.topic],
      lesson: f[col.lesson],
      seq: Number(f[col.seq]),
      line: Number(f[col.line]),
      target: f[col.target_file],
      description: f[col.description],
    };
  });
}

function itemDone(item) {
  return existsSync(join(repoRoot, item.target));
}

function itemsPayload() {
  return items.map((it) => ({ ...it, done: itemDone(it) }));
}

// --- Lesson context around a marker ---

async function markerContext(item) {
  const mdPath = item.topic
    ? join(repoRoot, 'content', 'lessons', item.subject, item.topic, `${item.lesson}.md`)
    : join(repoRoot, 'content', 'lessons', item.subject, `${item.lesson}.md`);
  const lines = (await readFile(mdPath, 'utf8')).split('\n');
  const from = Math.max(0, item.line - 9);
  const to = Math.min(lines.length, item.line + 8);
  return {
    from: from + 1,
    markerLine: item.line,
    lines: lines.slice(from, to),
  };
}

// --- Downloads watching ---

async function latestDownloads(limit = 5) {
  let names;
  try {
    names = await readdir(downloadsDir);
  } catch {
    return [];
  }
  const files = [];
  for (const name of names) {
    if (name.startsWith('.')) continue;
    if (!IMAGE_EXTS.has(extname(name).toLowerCase())) continue;
    try {
      const s = await stat(join(downloadsDir, name));
      if (!s.isFile()) continue;
      files.push({ name, path: join(downloadsDir, name), mtime: s.mtimeMs, size: s.size });
    } catch {
      /* file may have vanished mid-scan */
    }
  }
  files.sort((a, b) => b.mtime - a.mtime);
  return files.slice(0, limit);
}

// --- Connect: normalize + move ---

function sips(args) {
  return new Promise((resolvePromise, reject) => {
    const p = spawn('sips', args, { stdio: ['ignore', 'pipe', 'pipe'] });
    let out = '';
    p.stdout.on('data', (d) => (out += d));
    p.stderr.on('data', (d) => (out += d));
    p.on('error', reject);
    p.on('close', (code) =>
      code === 0 ? resolvePromise(out) : reject(new Error(`sips ${args[0]} failed:\n${out}`)),
    );
  });
}

async function pixelWidth(file) {
  const out = await sips(['-g', 'pixelWidth', file]);
  const m = out.match(/pixelWidth:\s*(\d+)/);
  return m ? Number(m[1]) : null;
}

// --- Copyright metadata stamp ---
// Splices a `tEXt` Copyright chunk into the PNG right after its header.
// Invisible in the app; visible to anyone inspecting a copied file.

const COPYRIGHT = `© ${new Date().getFullYear()} Pantas. All rights reserved.`;

function crc32(buf) {
  let crc = 0xffffffff;
  for (const byte of buf) {
    crc ^= byte;
    for (let k = 0; k < 8; k++) crc = crc & 1 ? 0xedb88320 ^ (crc >>> 1) : crc >>> 1;
  }
  return (crc ^ 0xffffffff) >>> 0;
}

function withCopyrightChunk(png, text) {
  const signature = Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]);
  if (png.length < 33 || !png.subarray(0, 8).equals(signature)) return png;
  const ihdrLength = png.readUInt32BE(8);
  const insertAt = 8 + 4 + 4 + ihdrLength + 4; // signature + IHDR len/type/data/crc
  const data = Buffer.from(`Copyright\0${text}`, 'latin1');
  const typeAndData = Buffer.concat([Buffer.from('tEXt', 'latin1'), data]);
  const lengthBytes = Buffer.alloc(4);
  lengthBytes.writeUInt32BE(data.length);
  const crcBytes = Buffer.alloc(4);
  crcBytes.writeUInt32BE(crc32(typeAndData));
  return Buffer.concat([
    png.subarray(0, insertAt), lengthBytes, typeAndData, crcBytes, png.subarray(insertAt),
  ]);
}

async function connect(item, sourcePath) {
  let source;
  try {
    source = await realpath(resolve(sourcePath));
  } catch {
    return { status: 400, error: `File not found: ${sourcePath}` };
  }
  if (!IMAGE_EXTS.has(extname(source).toLowerCase())) {
    return { status: 400, error: `Not an image file: ${basename(source)}` };
  }
  // Sources must come from Downloads or the user's home tree — never system paths.
  if (!(await isWithin(source, downloadsDir)) && !(await isWithin(source, homedir()))) {
    return { status: 400, error: 'Source must be in your Downloads or home folder.' };
  }

  const targetAbs = join(repoRoot, item.target);
  if (!targetAbs.startsWith(illusRoot + sep)) return { status: 400, error: 'Invalid target path.' };
  await mkdir(dirname(targetAbs), { recursive: true });

  const tmp = join(tmpdir(), `illus-${Date.now()}.png`);
  try {
    const width = await pixelWidth(source);
    const args = ['-s', 'format', 'png'];
    if (width && width > MAX_WIDTH) args.push('--resampleWidth', String(MAX_WIDTH));
    args.push(source, '--out', tmp);
    await sips(args);
    await writeFile(targetAbs, withCopyrightChunk(await readFile(tmp), COPYRIGHT));
    await unlink(tmp);
  } catch (error) {
    await unlink(tmp).catch(() => {});
    return { status: 500, error: `Could not process image: ${error.message}` };
  }

  // Move semantics: the original leaves Downloads once safely in the repo.
  // Only files inside Downloads are ever deleted; manual paths elsewhere
  // (Desktop, project folders) are left alone.
  let removedOriginal = false;
  if (await isWithin(source, downloadsDir)) {
    removedOriginal = await unlink(source).then(() => true).catch(() => false);
  }

  const s = await stat(targetAbs);
  return { status: 200, connected: true, target: item.target, bytes: s.size, removedOriginal };
}

// --- Static files & helpers ---

const staticRoutes = {
  '/': { file: join(toolDir, 'public', 'index.html'), type: 'text/html; charset=utf-8' },
  '/prompt_template.md': {
    file: join(toolDir, 'prompt_template.md'),
    type: 'text/plain; charset=utf-8',
  },
};

async function serveStatic(res, route) {
  try {
    const data = await readFile(route.file);
    res.writeHead(200, { 'Content-Type': route.type });
    res.end(data);
  } catch {
    res.writeHead(404);
    res.end('Not found');
  }
}

const imageTypes = {
  '.png': 'image/png', '.jpg': 'image/jpeg', '.jpeg': 'image/jpeg',
  '.webp': 'image/webp', '.gif': 'image/gif', '.heic': 'image/heic',
  '.tiff': 'image/tiff', '.bmp': 'image/bmp',
};

async function serveImage(res, absPath, allowedRoot) {
  const p = resolve(absPath);
  if (!(await isWithin(p, allowedRoot)) || !IMAGE_EXTS.has(extname(p).toLowerCase())) {
    res.writeHead(403);
    return res.end('Forbidden');
  }
  try {
    const data = await readFile(p);
    res.writeHead(200, {
      'Content-Type': imageTypes[extname(p).toLowerCase()] ?? 'application/octet-stream',
      'Cache-Control': 'no-store',
    });
    res.end(data);
  } catch {
    res.writeHead(404);
    res.end('Not found');
  }
}

function sendJson(res, status, payload) {
  res.writeHead(status, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify(payload));
}

function readBody(req) {
  return new Promise((resolvePromise, reject) => {
    let data = '';
    req.on('data', (chunk) => {
      data += chunk;
      if (data.length > 1_000_000) reject(new Error('Payload too large'));
    });
    req.on('end', () => resolvePromise(data));
    req.on('error', reject);
  });
}

// --- Server ---

// Loopback binding plus a Host check (blocks DNS-rebinding, where a hostile
// site resolves its own domain to 127.0.0.1 to reach this server).
const ALLOWED_HOSTS = new Set([`localhost:${PORT}`, `127.0.0.1:${PORT}`, `[::1]:${PORT}`]);

const server = createServer(async (req, res) => {
  if (!ALLOWED_HOSTS.has(req.headers.host ?? '')) {
    res.writeHead(403);
    return res.end('Forbidden');
  }
  const url = new URL(req.url, `http://localhost:${PORT}`);
  try {
    if (req.method === 'GET' && staticRoutes[url.pathname]) {
      return await serveStatic(res, staticRoutes[url.pathname]);
    }
    if (req.method === 'GET' && url.pathname === '/api/items') {
      return sendJson(res, 200, { items: itemsPayload(), downloadsDir });
    }
    if (req.method === 'GET' && url.pathname === '/api/context') {
      const item = items[Number(url.searchParams.get('index'))];
      if (!item) return sendJson(res, 404, { error: 'Unknown item.' });
      return sendJson(res, 200, await markerContext(item));
    }
    if (req.method === 'GET' && url.pathname === '/api/downloads') {
      return sendJson(res, 200, { files: await latestDownloads() });
    }
    if (req.method === 'GET' && url.pathname === '/api/preview/download') {
      return await serveImage(res, url.searchParams.get('path') ?? '', resolve(downloadsDir));
    }
    if (req.method === 'GET' && url.pathname === '/api/preview/connected') {
      const item = items[Number(url.searchParams.get('index'))];
      if (!item) return sendJson(res, 404, { error: 'Unknown item.' });
      return await serveImage(res, join(repoRoot, item.target), illusRoot);
    }
    if (req.method === 'POST' && url.pathname === '/api/connect') {
      const { index, source } = JSON.parse(await readBody(req));
      const item = items[Number(index)];
      if (!item) return sendJson(res, 404, { error: 'Unknown item.' });
      const result = await connect(item, String(source ?? ''));
      if (result.status === 200) {
        runPython().catch(() => {}); // refresh committed worklist.tsv in the background
      }
      return sendJson(res, result.status, result);
    }
    if (req.method === 'POST' && url.pathname === '/api/rescan') {
      await runPython();
      await loadWorklist();
      return sendJson(res, 200, { items: itemsPayload() });
    }
    res.writeHead(404);
    res.end('Not found');
  } catch (error) {
    sendJson(res, 500, { error: String(error?.message ?? error) });
  }
});

server.on('error', (error) => {
  if (error.code === 'EADDRINUSE') {
    console.log(
      `The Illustration Studio is already running — opening http://localhost:${PORT} in your browser.`,
    );
    if (process.platform === 'darwin') {
      spawn('open', [`http://localhost:${PORT}`], { stdio: 'ignore', detached: true }).unref();
    }
    process.exit(0);
  }
  throw error;
});

console.log('Scanning lessons for ILLUSTRATION markers...');
await runPython();
await loadWorklist();

server.listen(PORT, '127.0.0.1', () => {
  const url = `http://localhost:${PORT}`;
  const done = items.filter(itemDone).length;
  console.log(`Illustration Studio running at ${url}`);
  console.log(`${items.length} illustrations, ${done} connected so far.`);
  console.log(`Watching ${downloadsDir} for new images. Press Ctrl+C to stop.`);
  if (process.platform === 'darwin' && !process.argv.includes('--no-open')) {
    spawn('open', [url], { stdio: 'ignore', detached: true }).unref();
  }
});
