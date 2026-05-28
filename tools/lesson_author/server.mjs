// Local lesson authoring server. Serves the single-page UI and reads/writes
// lesson Markdown files under content/lessons/. No runtime dependencies;
// marked and katex are vendored from node_modules for the browser only.
import { createServer } from 'node:http';
import { readFile, writeFile, mkdir, access } from 'node:fs/promises';
import { existsSync } from 'node:fs';
import { spawn } from 'node:child_process';
import { dirname, join, normalize } from 'node:path';
import { fileURLToPath } from 'node:url';

const PORT = 4321;
const toolDir = dirname(fileURLToPath(import.meta.url));
const repoRoot = join(toolDir, '..', '..');
const contentRoot = join(repoRoot, 'content', 'lessons');

const outline = JSON.parse(await readFile(join(toolDir, 'outline.json'), 'utf8'));

// Flatten the outline into an ordered list; ids are derived from stable
// slugs so retitling a lesson never changes its identity or file path.
const lessons = [];
for (const subject of outline.subjects) {
  for (const topic of subject.topics) {
    for (const lesson of topic.lessons) {
      lessons.push({
        id: `lesson-${topic.slug}-${lesson.slug}`,
        subjectSlug: subject.slug,
        topicSlug: topic.slug,
        lessonSlug: lesson.slug,
        defaultTitle: lesson.title,
      });
    }
  }
}
const lessonsById = new Map(lessons.map((l) => [l.id, l]));

const lessonPath = (l) =>
  join(contentRoot, l.subjectSlug, l.topicSlug, `${l.lessonSlug}.md`);

// --- Minimal frontmatter (YAML subset: JSON-quoted strings, numbers, bools) ---

function serializeLesson({ id, lesson, title, summary, estimatedMinutes, body }) {
  const lines = [
    '---',
    `_id: ${JSON.stringify(id)}`,
    `title: ${JSON.stringify(title)}`,
    `summary: ${JSON.stringify(summary)}`,
    `subject: ${JSON.stringify(`subject-${lesson.subjectSlug}`)}`,
    `topic: ${JSON.stringify(`topic-${lesson.topicSlug}`)}`,
    `estimatedMinutes: ${estimatedMinutes}`,
    'isActive: true',
    '---',
    '',
  ];
  return lines.join('\n') + body.trim() + '\n';
}

function parseLessonFile(raw) {
  const match = raw.match(/^---\n([\s\S]*?)\n---\n?/);
  if (!match) return { meta: {}, body: raw };
  const meta = {};
  for (const line of match[1].split('\n')) {
    const sep = line.indexOf(': ');
    if (sep === -1) continue;
    const key = line.slice(0, sep);
    const rawValue = line.slice(sep + 2);
    if (rawValue.startsWith('"')) {
      try {
        meta[key] = JSON.parse(rawValue);
      } catch {
        meta[key] = rawValue;
      }
    } else if (rawValue === 'true' || rawValue === 'false') {
      meta[key] = rawValue === 'true';
    } else if (/^-?\d+$/.test(rawValue)) {
      meta[key] = Number(rawValue);
    } else {
      meta[key] = rawValue;
    }
  }
  return { meta, body: raw.slice(match[0].length).replace(/^\n/, '') };
}

// --- Static files ---

const staticRoutes = {
  '/': { file: join(toolDir, 'public', 'index.html'), type: 'text/html; charset=utf-8' },
  '/outline.json': { file: join(toolDir, 'outline.json'), type: 'application/json' },
  '/prompt_template.md': {
    file: join(toolDir, 'prompt_template.md'),
    type: 'text/plain; charset=utf-8',
  },
  '/vendor/marked.js': {
    file: join(toolDir, 'node_modules', 'marked', 'marked.min.js'),
    type: 'text/javascript',
  },
  '/vendor/katex.min.js': {
    file: join(toolDir, 'node_modules', 'katex', 'dist', 'katex.min.js'),
    type: 'text/javascript',
  },
  '/vendor/katex.min.css': {
    file: join(toolDir, 'node_modules', 'katex', 'dist', 'katex.min.css'),
    type: 'text/css',
  },
};

const fontTypes = { woff2: 'font/woff2', woff: 'font/woff', ttf: 'font/ttf' };

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

function sendJson(res, status, payload) {
  res.writeHead(status, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify(payload));
}

// --- API ---

async function lessonStatuses() {
  const statuses = {};
  await Promise.all(
    lessons.map(async (l) => {
      try {
        const raw = await readFile(lessonPath(l), 'utf8');
        const { meta } = parseLessonFile(raw);
        statuses[l.id] = {
          exists: true,
          title: meta.title ?? l.defaultTitle,
          summary: meta.summary ?? '',
          estimatedMinutes: meta.estimatedMinutes ?? null,
        };
      } catch {
        statuses[l.id] = { exists: false };
      }
    }),
  );
  return statuses;
}

async function readLesson(id) {
  const lesson = lessonsById.get(id);
  if (!lesson) return null;
  const raw = await readFile(lessonPath(lesson), 'utf8');
  const { meta, body } = parseLessonFile(raw);
  return {
    id,
    title: meta.title ?? lesson.defaultTitle,
    summary: meta.summary ?? '',
    estimatedMinutes: meta.estimatedMinutes ?? null,
    body,
  };
}

async function saveLesson(payload) {
  const { id, title, summary, estimatedMinutes, body } = payload;
  const lesson = lessonsById.get(id);
  if (!lesson) return { status: 404, error: `Unknown lesson id: ${id}` };
  if (typeof title !== 'string' || !title.trim()) {
    return { status: 400, error: 'Title is required.' };
  }
  if (typeof summary !== 'string' || !summary.trim()) {
    return { status: 400, error: 'Summary is required.' };
  }
  const minutes = Number(estimatedMinutes);
  if (!Number.isInteger(minutes) || minutes < 1) {
    return { status: 400, error: 'Estimated minutes must be a whole number of 1 or more.' };
  }
  if (typeof body !== 'string' || !body.trim()) {
    return { status: 400, error: 'Lesson content is empty.' };
  }
  const path = lessonPath(lesson);
  if (!normalize(path).startsWith(contentRoot)) {
    return { status: 400, error: 'Invalid path.' };
  }
  await mkdir(dirname(path), { recursive: true });
  await writeFile(
    path,
    serializeLesson({
      id,
      lesson,
      title: title.trim(),
      summary: summary.trim(),
      estimatedMinutes: minutes,
      body,
    }),
  );
  return { status: 200, saved: true };
}

function readBody(req) {
  return new Promise((resolve, reject) => {
    let data = '';
    req.on('data', (chunk) => {
      data += chunk;
      if (data.length > 5_000_000) reject(new Error('Payload too large'));
    });
    req.on('end', () => resolve(data));
    req.on('error', reject);
  });
}

const server = createServer(async (req, res) => {
  const url = new URL(req.url, `http://localhost:${PORT}`);
  try {
    if (req.method === 'GET' && staticRoutes[url.pathname]) {
      return await serveStatic(res, staticRoutes[url.pathname]);
    }
    if (req.method === 'GET' && url.pathname.startsWith('/vendor/fonts/')) {
      const name = url.pathname.slice('/vendor/fonts/'.length);
      if (!/^[\w.-]+$/.test(name)) {
        res.writeHead(400);
        return res.end('Bad font path');
      }
      const ext = name.split('.').pop();
      return await serveStatic(res, {
        file: join(toolDir, 'node_modules', 'katex', 'dist', 'fonts', name),
        type: fontTypes[ext] ?? 'application/octet-stream',
      });
    }
    if (req.method === 'GET' && url.pathname === '/api/lessons') {
      return sendJson(res, 200, await lessonStatuses());
    }
    if (req.method === 'GET' && url.pathname === '/api/lesson') {
      const id = url.searchParams.get('id') ?? '';
      try {
        const lesson = await readLesson(id);
        if (!lesson) return sendJson(res, 404, { error: `Unknown lesson id: ${id}` });
        return sendJson(res, 200, lesson);
      } catch {
        return sendJson(res, 404, { error: 'Lesson file not found.' });
      }
    }
    if (req.method === 'POST' && url.pathname === '/api/lesson') {
      const payload = JSON.parse(await readBody(req));
      const result = await saveLesson(payload);
      return sendJson(res, result.status, result);
    }
    res.writeHead(404);
    res.end('Not found');
  } catch (error) {
    sendJson(res, 500, { error: String(error?.message ?? error) });
  }
});

if (!existsSync(join(toolDir, 'node_modules'))) {
  console.log('First run: installing dependencies (marked, katex)...');
  await new Promise((resolve, reject) => {
    const npm = spawn('npm', ['install', '--no-audit', '--no-fund'], {
      cwd: toolDir,
      stdio: 'inherit',
    });
    npm.on('close', (code) =>
      code === 0 ? resolve() : reject(new Error(`npm install failed (exit ${code})`)),
    );
  });
}

server.on('error', (error) => {
  if (error.code === 'EADDRINUSE') {
    console.log(
      `The Lesson Author is already running — opening http://localhost:${PORT} in your browser.`,
    );
    if (process.platform === 'darwin') {
      spawn('open', [`http://localhost:${PORT}`], { stdio: 'ignore', detached: true }).unref();
    }
    process.exit(0);
  }
  throw error;
});

server.listen(PORT, () => {
  const url = `http://localhost:${PORT}`;
  console.log(`Lesson Author running at ${url}`);
  console.log(`Lessons are saved to ${contentRoot}`);
  console.log('Press Ctrl+C to stop.');
  if (process.platform === 'darwin' && !process.argv.includes('--no-open')) {
    spawn('open', [url], { stdio: 'ignore', detached: true }).unref();
  }
});
