// Local question review server. Renders/edits question YAML under
// content/questions/. Mirrors tools/lesson_author/server.mjs.
import { createServer } from 'node:http';
import { readFile, writeFile, mkdir, readdir } from 'node:fs/promises';
import { existsSync } from 'node:fs';
import { spawn } from 'node:child_process';
import { dirname, join, normalize } from 'node:path';
import { fileURLToPath } from 'node:url';

const PORT = Number(process.env.QSTUDIO_PORT ?? 4323);
const toolDir = dirname(fileURLToPath(import.meta.url));
const repoRoot = join(toolDir, '..', '..');
const contentRoot = join(repoRoot, 'content', 'questions');

if (!existsSync(join(toolDir, 'node_modules'))) {
  console.log('First run: installing dependencies (yaml)...');
  await new Promise((resolve, reject) => {
    const npm = spawn('npm', ['install', '--no-audit', '--no-fund'], { cwd: toolDir, stdio: 'inherit' });
    npm.on('close', (code) => (code === 0 ? resolve() : reject(new Error(`npm install failed (${code})`))));
  });
}
const YAML = (await import('yaml')).default;

const send = (res, status, payload) => {
  res.writeHead(status, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify(payload));
};

async function buildTree() {
  const tree = [];
  if (!existsSync(contentRoot)) return tree;
  for (const subject of (await readdir(contentRoot, { withFileTypes: true })).filter((d) => d.isDirectory())) {
    const topics = [];
    const subjectDir = join(contentRoot, subject.name);
    for (const topic of (await readdir(subjectDir, { withFileTypes: true })).filter((d) => d.isDirectory())) {
      const subtopics = [];
      const topicDir = join(subjectDir, topic.name);
      for (const file of (await readdir(topicDir, { withFileTypes: true })).filter((d) => d.isFile() && d.name.endsWith('.yaml'))) {
        const doc = YAML.parse(await readFile(join(topicDir, file.name), 'utf8')) ?? {};
        const questions = doc.questions ?? [];
        subtopics.push({
          id: `${subject.name}/${topic.name}/${file.name.replace(/\.yaml$/, '')}`,
          count: questions.length,
          approved: questions.filter((q) => q.approved === true).length,
          figurePending: questions.filter((q) => q.figure).length,
        });
      }
      topics.push({ name: topic.name, subtopics });
    }
    tree.push({ name: subject.name, topics });
  }
  return tree;
}

const yamlPathFor = (id) => {
  const path = normalize(join(contentRoot, `${id}.yaml`));
  if (!path.startsWith(contentRoot)) throw new Error('Invalid path');
  return path;
};

function readBody(req) {
  return new Promise((resolve, reject) => {
    let data = '';
    req.on('data', (c) => { data += c; if (data.length > 5_000_000) reject(new Error('Payload too large')); });
    req.on('end', () => resolve(data));
    req.on('error', reject);
  });
}

const server = createServer(async (req, res) => {
  const url = new URL(req.url, `http://localhost:${PORT}`);
  try {
    if (req.method === 'GET' && url.pathname === '/') {
      res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
      return res.end(await readFile(join(toolDir, 'public', 'index.html')));
    }
    if (req.method === 'GET' && url.pathname === '/prompt_template.md') {
      res.writeHead(200, { 'Content-Type': 'text/plain; charset=utf-8' });
      return res.end(await readFile(join(toolDir, 'prompt_template.md')));
    }
    if (req.method === 'GET' && url.pathname === '/validators.mjs') {
      res.writeHead(200, { 'Content-Type': 'text/javascript' });
      return res.end(await readFile(join(toolDir, 'validators.mjs')));
    }
    if (req.method === 'GET' && url.pathname === '/api/tree') {
      return send(res, 200, await buildTree());
    }
    if (req.method === 'GET' && url.pathname === '/api/subtopic') {
      const id = url.searchParams.get('id') ?? '';
      try {
        const doc = YAML.parse(await readFile(yamlPathFor(id), 'utf8'));
        return send(res, 200, doc);
      } catch {
        return send(res, 404, { error: `Not found: ${id}` });
      }
    }
    if (req.method === 'POST' && url.pathname === '/api/subtopic') {
      const { id, doc } = JSON.parse(await readBody(req));
      const path = yamlPathFor(id);
      await mkdir(dirname(path), { recursive: true });
      await writeFile(path, YAML.stringify(doc, { lineWidth: 0 }));
      return send(res, 200, { saved: true });
    }
    res.writeHead(404); res.end('Not found');
  } catch (error) {
    send(res, 500, { error: String(error?.message ?? error) });
  }
});

server.on('error', (error) => {
  if (error.code === 'EADDRINUSE') {
    console.log(`Question Studio already running — opening http://localhost:${PORT}`);
    if (process.platform === 'darwin') spawn('open', [`http://localhost:${PORT}`], { stdio: 'ignore', detached: true }).unref();
    process.exit(0);
  }
  throw error;
});

server.listen(PORT, () => {
  const url = `http://localhost:${PORT}`;
  console.log(`Question Studio running at ${url}`);
  console.log(`Reviewing questions in ${contentRoot}`);
  if (process.platform === 'darwin' && !process.argv.includes('--no-open')) {
    spawn('open', [url], { stdio: 'ignore', detached: true }).unref();
  }
});
