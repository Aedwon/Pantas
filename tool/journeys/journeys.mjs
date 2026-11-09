// Browser journeys against the local web run (tools/local/run_web_local.py).
// Each one is a failure a student or Aedwon actually hit. Flutter draws to a
// canvas, so text and tap targets are read through its semantics layer.
//
//   node tool/journeys/journeys.mjs [base url]
import {readFileSync, mkdirSync} from 'node:fs';
import {chromium} from 'playwright';

const BASE = process.argv[2] ?? 'http://127.0.0.1:7357';
const OUT = 'build/journeys';
mkdirSync(OUT, {recursive: true});

function cseLesson() {
  const export_ = JSON.parse(readFileSync('build/export.json', 'utf8'));
  const tagged = new Set(export_.question
    .filter(q => q.isActive !== false && q.lesson && q.examIds.some(e => e._ref === 'exam_cse_pro'))
    .map(q => q.lesson._ref));
  return export_.lesson.find(l => l.isActive !== false && tagged.has(l._id));
}

async function until(what, test, seconds, page) {
  const end = Date.now() + seconds * 1000;
  while (Date.now() < end) {
    const value = await test();
    if (value) return value;
    await page.waitForTimeout(500);
  }
  throw new Error(`Timed out after ${seconds}s waiting for ${what}`);
}

const semanticsOn = page => page.evaluate(() =>
  document.querySelector('flt-semantics-placeholder')?.click());

const labels = page => page.evaluate(() => {
  const found = new Set();
  for (const node of document.querySelectorAll('flt-semantics, flt-semantics *')) {
    const text = (node.getAttribute('aria-label') ?? '').trim();
    if (text) found.add(text);
    if (node.children.length === 0 && node.textContent.trim()) found.add(node.textContent.trim());
  }
  return [...found];
});

async function seeLabel(page, pattern, seconds, what) {
  return until(what ?? `a label matching ${pattern}`, async () => {
    await semanticsOn(page);
    return (await labels(page)).find(text => pattern.test(text));
  }, seconds, page);
}

async function refuse(page, pattern) {
  const bad = (await labels(page)).find(text => pattern.test(text));
  if (bad) throw new Error(`The page shows "${bad}"`);
}

// Clicks the semantics node for a label, wheeling the page until it is on screen.
async function clickLabel(page, pattern) {
  await page.mouse.move(720, 500);
  for (let i = 0; i < 60; i++) {
    await semanticsOn(page);
    const box = await page.evaluate(source => {
      const pattern = new RegExp(source);
      let best = null;
      for (const node of document.querySelectorAll('flt-semantics')) {
        const text = (node.getAttribute('aria-label') || node.textContent || '').trim();
        if (!pattern.test(text)) continue;
        const r = node.getBoundingClientRect();
        if (r.width > 0 && (!best || r.width * r.height < best.w * best.h)) {
          best = {x: r.x + r.width / 2, y: r.y + r.height / 2, w: r.width, h: r.height};
        }
      }
      return best;
    }, pattern.source);
    if (box && box.y > 0 && box.y < 860) {
      await page.mouse.click(box.x, box.y);
      return;
    }
    await page.mouse.wheel(0, 900);
    await page.waitForTimeout(300);
  }
  throw new Error(`No label matching ${pattern} came on screen`);
}

const inApp = (page, path) => page.evaluate(to => {
  history.pushState({}, '', to);
  window.dispatchEvent(new PopStateEvent('popstate', {state: history.state}));
}, path);

async function openStudent(page, account) {
  await page.goto(`${BASE}/?localAccount=${account}&localStudent=steady`,
    {waitUntil: 'domcontentloaded'});
  // The first visit passes through the reset page, then the seed runs.
  await until('Home', () => /\/home/.test(page.url()), 240, page);
}

const journeys = {
  // Nov 5: a Pro student reloading on a lesson got "Could not load this lesson".
  async 'Pro reload on a lesson shows the lesson'(page) {
    const lesson = cseLesson();
    await openStudent(page, 'pro');
    await inApp(page, `/lesson/${lesson._id}`);
    await seeLabel(page, new RegExp(lesson.title.slice(0, 20).replace(/[.*+?^${}()|[\]\\]/g, '\\$&')),
      60, 'the lesson before the reload');
    await page.reload({waitUntil: 'domcontentloaded'});
    await until('the lesson address after the reload', () => /\/lesson\//.test(page.url()), 30, page);
    await seeLabel(page, new RegExp(lesson.title.slice(0, 20).replace(/[.*+?^${}()|[\]\\]/g, '\\$&')),
      90, 'the lesson after the reload');
    await refuse(page, /Could not load this lesson/);
  },

  // Nov 5: lessons with no questions for the exam gave "Could not load your quiz".
  async 'Home to lesson to Quiz yourself draws a question'(page) {
    await openStudent(page, 'pro2');
    // Home draws from the plan first and adds Continue Lesson when today's
    // lesson is ready. A fixed 3.5 s wait pressed Enter before it existed on
    // slow runs (Nov 9: 6 of 8 runs failed this way while the app worked).
    await seeLabel(page, /^Continue Lesson/, 90, 'Continue Lesson on Home');
    await page.waitForTimeout(500);
    await page.keyboard.press('Enter');
    await until('a lesson opened from Home', () => /\/lesson\//.test(page.url()), 20, page);
    await page.waitForTimeout(3000);
    await clickLabel(page, /^Quiz yourself/);
    await until('the quiz address', () => /\/quiz\/inline\//.test(page.url()), 30, page);
    await seeLabel(page, /^Question 1 of|^Check$/, 60, 'the first question');
    await refuse(page, /Could not load your quiz/);
  },

  // A commit on IndexedDB stayed in memory until the next plain write, so the
  // last answer before a reload was lost.
  async 'The last answer survives a reload'(page) {
    await page.goto(`${BASE}/local-panel.html`, {waitUntil: 'load'});
    await page.evaluate(() => localStorage.setItem('pantas.local.preset', 'days'));
    await page.goto(`${BASE}/local-reset.html`, {waitUntil: 'domcontentloaded'});
    await seeLabel(page, /Which days will you study/, 120, 'Study days');
    await clickLabel(page, /^Continue/);
    await seeLabel(page, /What should we call you/, 30, 'Name');
    await page.waitForTimeout(1000);
    await page.reload({waitUntil: 'domcontentloaded'});
    await seeLabel(page, /What should we call you/, 90, 'Name after the reload');
  },

  // Every student starts here.
  async 'A first visit reaches onboarding'(page) {
    await page.goto(BASE, {waitUntil: 'domcontentloaded'});
    const start = page.locator('#pw-start');
    await start.waitFor({state: 'visible', timeout: 90000});
    await start.click();
    await until('onboarding', () => /\/onboarding/.test(page.url()), 90, page);
    await until('an onboarding screen with text', async () => {
      await semanticsOn(page);
      return (await labels(page)).length > 0;
    }, 30, page);
  },
};

const browser = await chromium.launch({
  args: ['--use-angle=swiftshader', '--enable-unsafe-swiftshader', '--ignore-gpu-blocklist'],
});
let failed = 0;
for (const [name, journey] of Object.entries(journeys)) {
  const context = await browser.newContext({
    viewport: {width: 1440, height: 900},
    // A runner with no system language gives the app an empty locale, and it stops at startup.
    locale: 'en-PH',
  });
  const page = await context.newPage();
  const errors = [];
  page.on('pageerror', error => errors.push(String(error).slice(0, 400)));
  const started = Date.now();
  try {
    await journey(page);
    console.log(`PASS  ${name} (${Math.round((Date.now() - started) / 1000)}s)`);
  } catch (error) {
    failed++;
    console.log(`FAIL  ${name}: ${error.message}`);
    console.log(`      at ${page.url()}`);
    console.log(`      labels: ${JSON.stringify((await labels(page).catch(() => [])).slice(0, 40))}`);
    for (const text of errors.slice(0, 5)) console.log(`      page error: ${text}`);
    await page.screenshot({path: `${OUT}/${name.replace(/\W+/g, '_')}.png`}).catch(() => {});
  }
  await context.close();
}
await browser.close();
process.exit(failed ? 1 : 0);
