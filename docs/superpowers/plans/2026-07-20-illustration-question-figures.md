# Connect Illustration Studio to Question Figures Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let Aedwon connect Downloads images to the 144 figure-pending questions in `content/questions/**/*.yaml`, using the existing Illustration Studio tool instead of a new one.

**Architecture:** A new pure-logic module scans `content/questions/**/*.yaml` for `figure:` slugs and builds items shaped like Illustration Studio's existing lesson items. `server.mjs` merges both item sources into one list (tagged `kind: 'lesson' | 'question'`); the frontend groups the sidebar by kind and renders a question's stem/choices/explanation in place of the lesson markdown context. The connect/resize/copyright-stamp pipeline is untouched — it already only cares about `item.target`.

**Tech Stack:** Node.js (native `node:http`, `node:test`), the `yaml` npm package (already used by `tools/question_studio`), vanilla JS/HTML frontend (no build step).

## Global Constraints

- Image target path: `content/illustrations/questions/<subject>/<topic>/<subtopic>/<slug>.png` (nested under the existing `content/illustrations/` root — no change needed to the server's containment check).
- `docs/content/question-figures/worklist.tsv` becomes a generated audit artifact (columns: `subject topic subtopic slug question_id target_file status`), regenerated on every server boot and `/api/rescan` — never hand-edited again.
- No changes to Question Studio, the quiz renderer, or `tools/import_questions/` — out of scope per the design doc.
- Follow the existing `tools/question_studio` pattern for adding the `yaml` dependency: `package.json` + `.gitignore` (`node_modules/`) + an npm-install-on-first-run bootstrap in `server.mjs`, committing the resulting `package-lock.json`.

---

### Task 1: `question_figures.mjs` — scan question YAML for figure slugs

**Files:**
- Create: `tools/illustration_studio/question_figures.mjs`
- Create: `tools/illustration_studio/question_figures.test.mjs`
- Create: `tools/illustration_studio/package.json`
- Create: `tools/illustration_studio/.gitignore`

**Interfaces:**
- Produces: `buildFigureItems(subject, topic, subtopic, doc)` → `Array<{kind:'question', subject, topic, subtopic, questionId, slug, stem, description, choices, explanation, target}>` (pure, no I/O).
- Produces: `worklistTsv(items)` → `string` (pure; expects each item to already carry a `.status` field).
- Produces: `async scanQuestionFigures(repoRoot)` → same array as `buildFigureItems`, gathered by walking `content/questions/**/*.yaml` (I/O — parses YAML via the `yaml` package).

- [ ] **Step 1: Write the failing tests**

Create `tools/illustration_studio/question_figures.test.mjs`:

```js
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { buildFigureItems, worklistTsv } from './question_figures.mjs';

const doc = {
  meta: { subject: 'reasoning', topic: 'mechanical-technical-reasoning', subtopic: 'structural-stability' },
  questions: [
    {
      id: 'q-mechanical-technical-reasoning-structural-stability-0001',
      figure: 'structural-stability-01',
      stem: 'Figure shows an object balanced on a point.',
      choices: [{ text: 'Center of gravity', correct: true }, { text: 'Fulcrum', correct: false }],
      explanation: 'The center of gravity is the balance point.',
    },
    {
      id: 'q-mechanical-technical-reasoning-structural-stability-0002',
      stem: 'No figure needed for this one.',
      choices: [{ text: 'A', correct: true }, { text: 'B', correct: false }],
      explanation: 'Plain text question.',
    },
  ],
};

test('buildFigureItems only includes questions with a figure slug', () => {
  const items = buildFigureItems('reasoning', 'mechanical-technical-reasoning', 'structural-stability', doc);
  assert.equal(items.length, 1);
  assert.equal(items[0].questionId, 'q-mechanical-technical-reasoning-structural-stability-0001');
});

test('buildFigureItems derives the target path from subject/topic/subtopic/slug', () => {
  const items = buildFigureItems('reasoning', 'mechanical-technical-reasoning', 'structural-stability', doc);
  assert.equal(
    items[0].target,
    'content/illustrations/questions/reasoning/mechanical-technical-reasoning/structural-stability/structural-stability-01.png',
  );
});

test('buildFigureItems uses the stem as the description', () => {
  const items = buildFigureItems('reasoning', 'mechanical-technical-reasoning', 'structural-stability', doc);
  assert.equal(items[0].description, 'Figure shows an object balanced on a point.');
});

test('buildFigureItems returns nothing for a doc with no questions', () => {
  assert.deepEqual(buildFigureItems('s', 't', 'st', {}), []);
});

test('worklistTsv writes a header and one tab-separated row per item', () => {
  const tsv = worklistTsv([
    {
      subject: 'reasoning', topic: 'mechanical-technical-reasoning', subtopic: 'structural-stability',
      slug: 'structural-stability-01', questionId: 'q-mechanical-technical-reasoning-structural-stability-0001',
      target: 'content/illustrations/questions/reasoning/mechanical-technical-reasoning/structural-stability/structural-stability-01.png',
      status: 'todo',
    },
  ]);
  const lines = tsv.trim().split('\n');
  assert.equal(lines[0], 'subject\ttopic\tsubtopic\tslug\tquestion_id\ttarget_file\tstatus');
  assert.equal(lines.length, 2);
  assert.equal(
    lines[1],
    'reasoning\tmechanical-technical-reasoning\tstructural-stability\tstructural-stability-01\t'
      + 'q-mechanical-technical-reasoning-structural-stability-0001\t'
      + 'content/illustrations/questions/reasoning/mechanical-technical-reasoning/structural-stability/structural-stability-01.png\ttodo',
  );
});
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `node --test tools/illustration_studio/question_figures.test.mjs`
Expected: FAIL — `Cannot find module './question_figures.mjs'`.

- [ ] **Step 3: Implement `question_figures.mjs`**

```js
// Scans content/questions/**/*.yaml for figure-pending questions and builds
// items shaped like Illustration Studio's lesson items, plus the
// docs/content/question-figures/worklist.tsv audit trail.
import { readFile, readdir } from 'node:fs/promises';
import { join } from 'node:path';

export function buildFigureItems(subject, topic, subtopic, doc) {
  const items = [];
  for (const q of doc?.questions ?? []) {
    if (!q.figure) continue;
    items.push({
      kind: 'question',
      subject,
      topic,
      subtopic,
      questionId: q.id,
      slug: q.figure,
      stem: q.stem,
      description: q.stem,
      choices: q.choices ?? [],
      explanation: q.explanation,
      target: `content/illustrations/questions/${subject}/${topic}/${subtopic}/${q.figure}.png`,
    });
  }
  return items;
}

export function worklistTsv(items) {
  const header = ['subject', 'topic', 'subtopic', 'slug', 'question_id', 'target_file', 'status'];
  const lines = [header.join('\t')];
  for (const it of items) {
    lines.push([it.subject, it.topic, it.subtopic, it.slug, it.questionId, it.target, it.status].join('\t'));
  }
  return lines.join('\n') + '\n';
}

export async function scanQuestionFigures(repoRoot) {
  const YAML = (await import('yaml')).default;
  const contentRoot = join(repoRoot, 'content', 'questions');
  const items = [];
  const subjects = (await readdir(contentRoot, { withFileTypes: true })).filter((d) => d.isDirectory());
  for (const subject of subjects) {
    const subjectDir = join(contentRoot, subject.name);
    const topics = (await readdir(subjectDir, { withFileTypes: true })).filter((d) => d.isDirectory());
    for (const topic of topics) {
      const topicDir = join(subjectDir, topic.name);
      const files = (await readdir(topicDir, { withFileTypes: true }))
        .filter((d) => d.isFile() && d.name.endsWith('.yaml'));
      for (const file of files) {
        const subtopic = file.name.replace(/\.yaml$/, '');
        const doc = YAML.parse(await readFile(join(topicDir, file.name), 'utf8')) ?? {};
        items.push(...buildFigureItems(subject.name, topic.name, subtopic, doc));
      }
    }
  }
  return items;
}
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `node --test tools/illustration_studio/question_figures.test.mjs`
Expected: PASS — 5 tests, 0 failures. (`scanQuestionFigures` isn't covered here since it needs the `yaml` package installed — that's proven in Step 6.)

- [ ] **Step 5: Add the `yaml` dependency**

Create `tools/illustration_studio/package.json`:

```json
{
  "name": "illustration-studio",
  "private": true,
  "type": "module",
  "dependencies": {
    "yaml": "^2.4.5"
  }
}
```

Create `tools/illustration_studio/.gitignore`:

```
node_modules/
```

Run: `cd tools/illustration_studio && npm install --no-audit --no-fund && cd -`
Expected: creates `node_modules/` and `package-lock.json` with no errors.

- [ ] **Step 6: Smoke-test `scanQuestionFigures` against the real content directory**

Run:

```bash
node -e "
import('./tools/illustration_studio/question_figures.mjs').then(async ({ scanQuestionFigures }) => {
  const items = await scanQuestionFigures(process.cwd());
  console.log('total figure items:', items.length);
  console.log(JSON.stringify(items[0], null, 2));
});
"
```

Expected: `total figure items: 144`, and the sample item's `target` starts with
`content/illustrations/questions/reasoning/`.

- [ ] **Step 7: Commit**

```bash
git add tools/illustration_studio/question_figures.mjs \
        tools/illustration_studio/question_figures.test.mjs \
        tools/illustration_studio/package.json \
        tools/illustration_studio/package-lock.json \
        tools/illustration_studio/.gitignore
git commit -m "feat(illustration-studio): scan question YAML for figure-pending slugs"
```

---

### Task 2: Merge question figures into `server.mjs`

**Files:**
- Modify: `tools/illustration_studio/server.mjs`

**Interfaces:**
- Consumes: `buildFigureItems`, `worklistTsv`, `scanQuestionFigures` from Task 1's `./question_figures.mjs`.
- Produces: the merged `items` array (module-level `let items = []`, unchanged variable name) now contains both `kind: 'lesson'` and `kind: 'question'` entries — every downstream consumer (`itemDone`, `itemsPayload`, `/api/connect`, `/api/preview/*`) keeps working unmodified because they only touch `item.target`.

- [ ] **Step 1: Add the npm-install bootstrap and the question-figures worklist path**

In `tools/illustration_studio/server.mjs`, replace:

```js
const PORT = Number(process.env.ILLUS_PORT ?? 4322);
const toolDir = dirname(fileURLToPath(import.meta.url));
const repoRoot = resolve(toolDir, '..', '..');
const illusRoot = join(repoRoot, 'content', 'illustrations');
const worklistPath = join(repoRoot, 'docs', 'content', 'illustrations', 'worklist.tsv');
const downloadsDir = process.env.ILLUS_DOWNLOADS_DIR ?? join(homedir(), 'Downloads');
```

with:

```js
const PORT = Number(process.env.ILLUS_PORT ?? 4322);
const toolDir = dirname(fileURLToPath(import.meta.url));
const repoRoot = resolve(toolDir, '..', '..');
const illusRoot = join(repoRoot, 'content', 'illustrations');
const worklistPath = join(repoRoot, 'docs', 'content', 'illustrations', 'worklist.tsv');
const questionFiguresWorklistPath = join(repoRoot, 'docs', 'content', 'question-figures', 'worklist.tsv');
const downloadsDir = process.env.ILLUS_DOWNLOADS_DIR ?? join(homedir(), 'Downloads');

if (!existsSync(join(toolDir, 'node_modules'))) {
  console.log('First run: installing dependencies (yaml)...');
  await new Promise((resolvePromise, reject) => {
    const npm = spawn('npm', ['install', '--no-audit', '--no-fund'], { cwd: toolDir, stdio: 'inherit' });
    npm.on('close', (code) => (code === 0 ? resolvePromise() : reject(new Error(`npm install failed (${code})`))));
  });
}
const { scanQuestionFigures, worklistTsv } = await import('./question_figures.mjs');
```

- [ ] **Step 2: Split lesson parsing out and add question-item loading**

Replace:

```js
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
```

with:

```js
let items = [];

function parseLessonWorklist(raw) {
  const lines = raw.trim().split('\n');
  const header = lines.shift().split('\t');
  const col = Object.fromEntries(header.map((h, i) => [h, i]));
  return lines.map((line) => {
    const f = line.split('\t');
    return {
      kind: 'lesson',
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

async function loadQuestionItems() {
  const questionItems = await scanQuestionFigures(repoRoot);
  const withStatus = questionItems.map((it) => ({
    ...it,
    status: existsSync(join(repoRoot, it.target)) ? 'done' : 'todo',
  }));
  await mkdir(dirname(questionFiguresWorklistPath), { recursive: true });
  await writeFile(questionFiguresWorklistPath, worklistTsv(withStatus));
  return questionItems;
}

async function loadWorklist() {
  const raw = await readFile(worklistPath, 'utf8');
  const lessonItems = parseLessonWorklist(raw);
  const questionItems = await loadQuestionItems();
  items = [...lessonItems, ...questionItems].map((it, index) => ({ ...it, index }));
}
```

- [ ] **Step 3: Guard `/api/context` for question items**

Replace:

```js
    if (req.method === 'GET' && url.pathname === '/api/context') {
      const item = items[Number(url.searchParams.get('index'))];
      if (!item) return sendJson(res, 404, { error: 'Unknown item.' });
      return sendJson(res, 200, await markerContext(item));
    }
```

with:

```js
    if (req.method === 'GET' && url.pathname === '/api/context') {
      const item = items[Number(url.searchParams.get('index'))];
      if (!item) return sendJson(res, 404, { error: 'Unknown item.' });
      if (item.kind === 'question') {
        return sendJson(res, 200, {
          kind: 'question', stem: item.stem, choices: item.choices, explanation: item.explanation,
        });
      }
      return sendJson(res, 200, await markerContext(item));
    }
```

(This endpoint is not called by the frontend for question items after Task 3 — they render inline from the `/api/items` payload — but guarding it here avoids a 500 if anything ever hits it for a question index.)

- [ ] **Step 4: Update the boot log line**

Replace:

```js
console.log('Scanning lessons for ILLUSTRATION markers...');
await runPython();
await loadWorklist();
```

with:

```js
console.log('Scanning lessons and question figures...');
await runPython();
await loadWorklist();
```

- [ ] **Step 5: Verify the merged item list and regenerated worklist**

Run:

```bash
cd /Users/aedwon/Documents/Projects/Pantas
ILLUS_PORT=4399 node tools/illustration_studio/server.mjs --no-open &
sleep 1
curl -s http://localhost:4399/api/items > /tmp/illus_items.json
node -e "
  const { items } = require('/tmp/illus_items.json');
  const q = items.filter((i) => i.kind === 'question');
  console.log('question items:', q.length);
  console.log('all pending:', q.every((i) => i.done === false));
  console.log('sample target:', q[0].target);
"
wc -l docs/content/question-figures/worklist.tsv
head -1 docs/content/question-figures/worklist.tsv
```

Expected: `question items: 144`, `all pending: true`, sample target starting
with `content/illustrations/questions/`, worklist has `145` lines (header +
144), header reads `subject\ttopic\tsubtopic\tslug\tquestion_id\ttarget_file\tstatus`.

- [ ] **Step 6: Verify the full connect round-trip for a question item**

With the server from Step 5 still running:

```bash
mkdir -p /tmp/illus_test_downloads
python3 -c "
import struct, zlib
def chunk(tag, data):
    return struct.pack('>I', len(data)) + tag + data + struct.pack('>I', zlib.crc32(tag + data))
width, height = 10, 10
raw = b''.join(b'\x00' + b'\xff\x00\x00' * width for _ in range(height))
png = b'\x89PNG\r\n\x1a\n'
png += chunk(b'IHDR', struct.pack('>IIBBBBB', width, height, 8, 2, 0, 0, 0))
png += chunk(b'IDAT', zlib.compress(raw))
png += chunk(b'IEND', b'')
open('/tmp/illus_test_downloads/test.png', 'wb').write(png)
"
QID=$(node -e "
  const { items } = require('/tmp/illus_items.json');
  console.log(items.findIndex((i) => i.kind === 'question' && !i.done));
")
curl -s -X POST http://localhost:4399/api/connect \
  -H 'Content-Type: application/json' \
  -d "{\"index\": $QID, \"source\": \"/tmp/illus_test_downloads/test.png\"}"
find content/illustrations/questions -name '*.png'
```

Expected: the curl response is JSON with `"connected":true` and a `target`
under `content/illustrations/questions/...`; the `find` shows exactly one PNG.

Now undo the test artifact and confirm rescan re-derives status cleanly:

```bash
rm -rf content/illustrations/questions
curl -s -X POST http://localhost:4399/api/rescan | node -e "
  let data = '';
  process.stdin.on('data', (d) => (data += d));
  process.stdin.on('end', () => {
    const { items } = JSON.parse(data);
    const q = items.filter((i) => i.kind === 'question');
    console.log('question items after rescan:', q.length);
    console.log('all pending again:', q.every((i) => i.done === false));
  });
"
kill %1
rm -rf /tmp/illus_test_downloads /tmp/illus_items.json
```

Expected: `question items after rescan: 144`, `all pending again: true`.
`git status` should now show only source changes plus a regenerated
`docs/content/question-figures/worklist.tsv` — no stray files under
`content/illustrations/questions/`.

- [ ] **Step 7: Commit**

```bash
git add tools/illustration_studio/server.mjs docs/content/question-figures/worklist.tsv
git commit -m "feat(illustration-studio): merge question figures into the item list"
```

---

### Task 3: Frontend — group by kind, render question context

**Files:**
- Modify: `tools/illustration_studio/public/index.html`

**Interfaces:**
- Consumes: `items[i].kind`, and for `kind: 'question'`: `subtopic`, `slug`, `stem`, `choices` (`{text, correct}[]`), `explanation` — all present on the `/api/items` payload from Task 2.

- [ ] **Step 1: Add label/grouping/context helpers and update `renderSidebar`**

Replace:

```js
function renderSidebar() {
  const nav = $('sidebar');
  let html = '';
  let lastGroup = '';
  items.forEach((it, i) => {
    const group = `${titleCase(it.subject)} · ${titleCase(it.topic || it.subject)}`;
    if (group !== lastGroup) {
      html += `<div class="topic-label">${esc(group)}</div>`;
      lastGroup = group;
    }
    html += `<button class="item ${it.done ? 'done' : ''} ${i === current ? 'current' : ''}" data-i="${i}">
      <span class="dot"></span>
      <span class="label">${esc(titleCase(it.lesson))} · #${it.seq}</span>
    </button>`;
  });
  nav.innerHTML = html;
  nav.querySelectorAll('button.item').forEach((b) =>
    b.addEventListener('click', () => show(Number(b.dataset.i))),
  );
  const cur = nav.querySelector('.current');
  if (cur) cur.scrollIntoView({ block: 'nearest' });
}
```

with:

```js
function itemLabel(it) {
  return it.kind === 'lesson'
    ? `${titleCase(it.lesson)} · #${it.seq}`
    : `${titleCase(it.subtopic)} · ${it.slug}`;
}

function itemGroup(it) {
  const kindLabel = it.kind === 'lesson' ? 'Lessons' : 'Questions';
  return `${kindLabel} — ${titleCase(it.subject)} · ${titleCase(it.topic || it.subject)}`;
}

function renderSidebar() {
  const nav = $('sidebar');
  let html = '';
  let lastGroup = '';
  items.forEach((it, i) => {
    const group = itemGroup(it);
    if (group !== lastGroup) {
      html += `<div class="topic-label">${esc(group)}</div>`;
      lastGroup = group;
    }
    html += `<button class="item ${it.done ? 'done' : ''} ${i === current ? 'current' : ''}" data-i="${i}">
      <span class="dot"></span>
      <span class="label">${esc(itemLabel(it))}</span>
    </button>`;
  });
  nav.innerHTML = html;
  nav.querySelectorAll('button.item').forEach((b) =>
    b.addEventListener('click', () => show(Number(b.dataset.i))),
  );
  const cur = nav.querySelector('.current');
  if (cur) cur.scrollIntoView({ block: 'nearest' });
}
```

- [ ] **Step 2: Add `crumbsFor`, `siblingStats`, and `questionContextHtml` helpers**

Directly above `async function show(index) {`, add:

```js
function crumbsFor(it) {
  const last = it.kind === 'lesson' ? it.lesson : it.subtopic;
  return `${esc(titleCase(it.subject))} → ${esc(titleCase(it.topic || ''))} → <b>${esc(titleCase(last))}</b>`;
}

function siblingStats(it) {
  if (it.kind === 'lesson') {
    const siblings = items.filter((x) => x.kind === 'lesson' && x.lesson === it.lesson && x.subject === it.subject && x.topic === it.topic);
    return { n: it.seq, total: siblings.length };
  }
  const siblings = items.filter((x) => x.kind === 'question' && x.subtopic === it.subtopic && x.subject === it.subject && x.topic === it.topic);
  return { n: siblings.findIndex((x) => x.slug === it.slug) + 1, total: siblings.length };
}

function questionContextHtml(it) {
  const choicesHtml = it.choices.map((c) => (
    c.correct
      ? `<li style="font-weight:700;color:var(--board)">${esc(c.text)} ✓</li>`
      : `<li>${esc(c.text)}</li>`
  )).join('');
  return `
    <div class="desc" style="margin-bottom:10px">${esc(it.stem)}</div>
    <ul style="margin:0 0 10px 20px;padding:0">${choicesHtml}</ul>
    <div style="font-size:13px;color:var(--ink-soft)">${esc(it.explanation)}</div>
  `;
}
```

- [ ] **Step 3: Make `show()` render crumbs/header/context per kind**

Replace:

```js
async function show(index) {
  current = Math.max(0, Math.min(items.length - 1, index));
  selectedSource = null;
  const it = items[current];

  const connectedPreview = it.done
    ? `<img src="/api/preview/connected?index=${current}&t=${Date.now()}" alt="connected illustration">`
    : `<div class="empty">Nothing connected yet</div>`;

  $('main').innerHTML = `
    <div class="crumbs">${esc(titleCase(it.subject))} → ${esc(titleCase(it.topic || ''))} → <b>${esc(titleCase(it.lesson))}</b></div>
    <h2>Illustration #${it.seq} of ${items.filter((x) => x.lesson === it.lesson && x.subject === it.subject && x.topic === it.topic).length}
      <span class="pill ${it.done ? 'done' : ''}">${it.done ? 'CONNECTED' : 'NEEDED'}</span>
    </h2>

    <div class="nav-buttons">
      <button class="ghost" id="btnPrev">← Prev</button>
      <button class="ghost" id="btnNext">Next →</button>
      <button class="ghost" id="btnNextTodo">Skip to next needed ↷</button>
    </div>

    <div class="card">
      <h3>What to draw</h3>
      <div class="desc">${esc(it.description)}</div>
      <div style="margin-top:10px" class="row">
        <button class="primary" id="btnCopy">Copy generation prompt</button>
        <span style="font-size:12px;color:var(--ink-soft)">paste into your AI tool, or use as your Canva/Illustrator brief</span>
      </div>
    </div>

    <div class="card">
      <h3>Where it sits in the lesson</h3>
      <div class="context" id="context">Loading…</div>
    </div>

    <div class="grid2">
      <div class="card">
        <h3>Latest in Downloads</h3>
        <div class="preview-box" id="dlPreview"><div class="empty">Watching ${esc(downloadsDir)}…<br>Export or download an image and it appears here.</div></div>
        <div class="file-meta" id="dlMeta"></div>
        <div class="row" style="margin-bottom:10px">
          <button class="primary" id="btnConnect" disabled>Connect ⇒ ${esc(it.target.split('/').pop())}</button>
        </div>
        <input class="path" id="manualPath" placeholder="…or paste a full file path here">
      </div>

      <div class="card">
        <h3>Connected file</h3>
        <div class="preview-box" id="connectedPreview">${connectedPreview}</div>
        <div class="target-path">${esc(it.target)}</div>
      </div>
    </div>
  `;

  $('btnPrev').onclick = () => show(current - 1);
  $('btnNext').onclick = () => show(current + 1);
  $('btnNextTodo').onclick = () => {
    const next = items.findIndex((x, i) => i > current && !x.done);
    const wrap = next === -1 ? items.findIndex((x) => !x.done) : next;
    if (wrap === -1) flash('All illustrations are connected! 🎉');
    else show(wrap);
  };
  $('btnCopy').onclick = async () => {
    await navigator.clipboard.writeText(buildPrompt(it));
    flash('Prompt copied — paste it into your generator');
  };
  $('btnConnect').onclick = doConnect;
  $('manualPath').addEventListener('input', (e) => {
    const v = e.target.value.trim();
    if (v) {
      selectedSource = v;
      $('btnConnect').disabled = false;
      $('dlMeta').textContent = `Manual: ${v}`;
    }
  });

  renderSidebar();
  renderProgress();
  loadContext();
  pollDownloads(true);
}
```

with:

```js
async function show(index) {
  current = Math.max(0, Math.min(items.length - 1, index));
  selectedSource = null;
  const it = items[current];
  const stats = siblingStats(it);

  const connectedPreview = it.done
    ? `<img src="/api/preview/connected?index=${current}&t=${Date.now()}" alt="connected illustration">`
    : `<div class="empty">Nothing connected yet</div>`;

  const contextCardTitle = it.kind === 'lesson' ? 'Where it sits in the lesson' : 'The question this illustrates';
  const contextCardBody = it.kind === 'lesson'
    ? '<div class="context" id="context">Loading…</div>'
    : `<div id="context">${questionContextHtml(it)}</div>`;

  $('main').innerHTML = `
    <div class="crumbs">${crumbsFor(it)}</div>
    <h2>Illustration #${stats.n} of ${stats.total}
      <span class="pill ${it.done ? 'done' : ''}">${it.done ? 'CONNECTED' : 'NEEDED'}</span>
    </h2>

    <div class="nav-buttons">
      <button class="ghost" id="btnPrev">← Prev</button>
      <button class="ghost" id="btnNext">Next →</button>
      <button class="ghost" id="btnNextTodo">Skip to next needed ↷</button>
    </div>

    <div class="card">
      <h3>What to draw</h3>
      <div class="desc">${esc(it.description)}</div>
      <div style="margin-top:10px" class="row">
        <button class="primary" id="btnCopy">Copy generation prompt</button>
        <span style="font-size:12px;color:var(--ink-soft)">paste into your AI tool, or use as your Canva/Illustrator brief</span>
      </div>
    </div>

    <div class="card">
      <h3>${esc(contextCardTitle)}</h3>
      ${contextCardBody}
    </div>

    <div class="grid2">
      <div class="card">
        <h3>Latest in Downloads</h3>
        <div class="preview-box" id="dlPreview"><div class="empty">Watching ${esc(downloadsDir)}…<br>Export or download an image and it appears here.</div></div>
        <div class="file-meta" id="dlMeta"></div>
        <div class="row" style="margin-bottom:10px">
          <button class="primary" id="btnConnect" disabled>Connect ⇒ ${esc(it.target.split('/').pop())}</button>
        </div>
        <input class="path" id="manualPath" placeholder="…or paste a full file path here">
      </div>

      <div class="card">
        <h3>Connected file</h3>
        <div class="preview-box" id="connectedPreview">${connectedPreview}</div>
        <div class="target-path">${esc(it.target)}</div>
      </div>
    </div>
  `;

  $('btnPrev').onclick = () => show(current - 1);
  $('btnNext').onclick = () => show(current + 1);
  $('btnNextTodo').onclick = () => {
    const next = items.findIndex((x, i) => i > current && !x.done);
    const wrap = next === -1 ? items.findIndex((x) => !x.done) : next;
    if (wrap === -1) flash('All illustrations are connected! 🎉');
    else show(wrap);
  };
  $('btnCopy').onclick = async () => {
    await navigator.clipboard.writeText(buildPrompt(it));
    flash('Prompt copied — paste it into your generator');
  };
  $('btnConnect').onclick = doConnect;
  $('manualPath').addEventListener('input', (e) => {
    const v = e.target.value.trim();
    if (v) {
      selectedSource = v;
      $('btnConnect').disabled = false;
      $('dlMeta').textContent = `Manual: ${v}`;
    }
  });

  renderSidebar();
  renderProgress();
  if (it.kind === 'lesson') loadContext();
  pollDownloads(true);
}
```

- [ ] **Step 4: Manual browser verification**

```bash
cd /Users/aedwon/Documents/Projects/Pantas
ILLUS_PORT=4399 node tools/illustration_studio/server.mjs --no-open &
sleep 1
```

Using the chrome-devtools MCP tools (`new_page`, `navigate_page` to
`http://localhost:4399/`, `take_snapshot`):

- Confirm the sidebar shows at least one `Lessons — ...` group and at least
  one `Questions — ...` group.
- Click a list item under a `Questions —` group. Confirm the main panel's
  second card is titled "The question this illustrates" and shows the
  question's stem text, its choices (one marked with ✓), and its
  explanation — with no "Loading…" flash (context renders synchronously for
  questions).
- Click a list item under a `Lessons —` group. Confirm the card is titled
  "Where it sits in the lesson" and still shows the markdown-context view
  (unchanged behavior).

Then:

```bash
kill %1
```

- [ ] **Step 5: Commit**

```bash
git add tools/illustration_studio/public/index.html
git commit -m "feat(illustration-studio): group sidebar by kind, render question context"
```

---

### Task 4: Update the authoring runbook

**Files:**
- Modify: `docs/content/question-authoring-runbook.md`

- [ ] **Step 1: Replace the manual-append instruction**

Replace:

```
7. **Figure-pending questions**: for every question with a `figure:` slug,
   append a row to `docs/content/question-figures/worklist.tsv` (slug,
   subject, topic, subtopic, question id, status `pending`). These import as
   `isActive: false` until an illustration exists and the renderer that
   displays it ships (tracked separately).
```

with:

```
7. **Figure-pending questions**: add a `figure: <slug>` to any question that
   needs one, then run Illustration Studio:
   ```bash
   node "tools/illustration_studio/Start Illustration Studio.command"
   ```
   It scans every `figure:` slug automatically and regenerates
   `docs/content/question-figures/worklist.tsv` — no manual worklist editing.
   Use the "Questions" group in the sidebar to connect an image to each slug.
   Figure-pending questions import as `isActive: false` until an illustration
   exists and the renderer that displays it ships (tracked separately).
```

- [ ] **Step 2: Commit**

```bash
git add docs/content/question-authoring-runbook.md
git commit -m "docs: point figure-pending step at the merged Illustration Studio"
```
