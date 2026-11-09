// Browser journeys against the local web run (tools/local/run_web_local.py).
// Each one is a failure a student or Aedwon actually hit. Flutter draws to a
// canvas, so text and tap targets are read through its semantics layer.
//
//   node tool/journeys/journeys.mjs [base url] [part of a journey name]
import {readFileSync, mkdirSync, statSync} from 'node:fs';
import {chromium} from 'playwright';

const BASE = process.argv[2] ?? 'http://127.0.0.1:7357';
const ONLY = process.argv[3];
const EMULATOR_LOG = process.env.EMULATOR_LOG ?? 'build/local-web/emulators.log';
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
  let last = '';
  while (Date.now() < end) {
    // A page that is navigating destroys the context a read ran in. Try again.
    const value = await Promise.resolve().then(test).catch(error => { last = String(error.message).split('\n')[0]; return null; });
    if (value) return value;
    await page.waitForTimeout(500);
  }
  throw new Error(`Timed out after ${seconds}s waiting for ${what}${last ? ` (last error: ${last})` : ''}`);
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
  // The welcome splash covers a first visit for a few seconds and takes the click.
  await page.locator('#pantas-splash').waitFor({state: 'hidden', timeout: 60000}).catch(() => {});
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

// The functions emulator prints the guardian email instead of sending it, so a
// journey reads the links from its log. Nothing in the app or the functions is
// there only for tests. `since` is the log size before the email was asked for.
const logSize = () => { try { return statSync(EMULATOR_LOG).size; } catch { return 0; } };
const logSince = since => {
  try { return readFileSync(EMULATOR_LOG).subarray(since).toString('utf8'); } catch { return ''; }
};
function guardianLinks(since) {
  const text = logSince(since);
  const last = pattern => [...text.matchAll(pattern)].at(-1)?.[1];
  const confirm = last(/\/guardian\?token=([a-f0-9]{64})/g);
  const manage = last(/\/guardian\/manage\?token=([a-f0-9]{64})/g);
  return confirm && manage ? {confirm, manage} : null;
}
// A callable that finished without an error since `since`. A change with no
// message on screen is only saved once the server says so, and a reload before
// that cancels it.
const callSucceeded = (since, name) =>
  new RegExp(`"fn":"${name}"[^}]*"outcome":"ok"`).test(logSince(since));

// 'true' or 'false' for the checkbox or switch whose label matches, or null.
const controlState = (page, pattern) => page.evaluate(source => {
  const pattern = new RegExp(source);
  for (const node of document.querySelectorAll('flt-semantics')) {
    const text = (node.getAttribute('aria-label') || '').trim();
    if (pattern.test(text) && node.hasAttribute('aria-checked')) return node.getAttribute('aria-checked');
  }
  return null;
}, pattern.source);

// Clicks a checkbox or switch until it shows the wanted state. A click in the
// first moments after a page appears can land before the page takes input.
async function setControl(page, pattern, wanted) {
  for (let attempt = 0; attempt < 6; attempt++) {
    await semanticsOn(page);
    if ((await controlState(page, pattern)) === String(wanted)) return;
    await clickLabel(page, pattern);
    await page.waitForTimeout(800);
  }
  throw new Error(`${pattern} did not turn ${wanted ? 'on' : 'off'}`);
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

  // Nov 10: a guardian can turn sharing off and withdraw from the manage page,
  // and the student's account ends. The student is a 16-year-old on a new
  // browser; the guardian's links come from the emulator's mail log.
  async 'A guardian confirms, manages and withdraws, and the student is signed out'(page) {
    const student = page;
    const year = new Date().getFullYear() - 16;
    await student.goto(`${BASE}/local-panel.html`, {waitUntil: 'load'});
    await student.evaluate(() => localStorage.setItem('pantas.local.preset', 'birthYear'));
    await student.goto(`${BASE}/local-reset.html`, {waitUntil: 'domcontentloaded'});
    await seeLabel(student, /Birth year/, 120, 'the Birth year step');
    await clickLabel(student, /Birth year/);
    await student.waitForTimeout(700);
    await student.keyboard.type(String(year), {delay: 50});
    await student.waitForTimeout(500);
    await clickLabel(student, /^Continue/);
    await seeLabel(student, /A parent or guardian needs to agree first/, 60, 'the guardian step');
    // The first field has the keys already, as the page says.
    await student.waitForTimeout(1000);
    await student.keyboard.type('Maria Santos', {delay: 30});
    await student.keyboard.press('Tab');
    await student.waitForTimeout(700);
    // A new address each run: the server allows three requests a day to one address.
    await student.keyboard.type(`maria.${Date.now()}@example.com`, {delay: 30});
    const before = logSize();
    await clickLabel(student, /^Send Link/);
    await seeLabel(student, /Waiting for your parent or guardian/, 60, 'the waiting page');
    const links = await until('the guardian email in the emulator log',
      async () => guardianLinks(before), 60, student);

    // The guardian opens the links in another browser, signed out.
    const guardian = await student.context().browser().newContext({
      viewport: {width: 1440, height: 900}, locale: 'en-PH',
    });
    const g = await guardian.newPage();
    try {
      await g.goto(`${BASE}/guardian?token=${links.confirm}`, {waitUntil: 'domcontentloaded'});
      await seeLabel(g, /Confirm your child's account/, 90, 'the confirm page');
      await setControl(g, /I'm their parent or guardian, and I agree/, true);
      await setControl(g, /Allow optional usage sharing/, true);
      await clickLabel(g, /^Confirm$/);
      await seeLabel(g, /^Thank you/, 60, 'Thank you');
      await clickLabel(g, /^Manage Permission/);
      await until('the manage address', () => /\/guardian\/manage\?token=/.test(g.url()), 30, g);
      await seeLabel(g, /^Manage permission/, 60, 'the manage page');
      await until('sharing shown on, as the guardian allowed it',
        async () => (await controlState(g, /Allow optional usage sharing/)) === 'true', 30, g);

      // Sharing off applies at once and stays after a reload.
      const beforeOff = logSize();
      await setControl(g, /Allow optional usage sharing/, false);
      await until('the server to save sharing off',
        async () => callSucceeded(beforeOff, 'setGuardianSharing'), 30, g);
      await refuse(g, /Your change was not saved/);
      await g.reload({waitUntil: 'domcontentloaded'});
      await seeLabel(g, /^Manage permission/, 90, 'the manage page after a reload');
      await until('sharing still off after the reload',
        async () => (await controlState(g, /Allow optional usage sharing/)) === 'false', 30, g);

      // Withdraw asks once, then the account closes.
      await clickLabel(g, /^Withdraw Permission/);
      await seeLabel(g, /^Your child is signed out, and their account/, 30, 'the Withdraw dialog');
      await clickLabel(g, /^Withdraw$/);
      await seeLabel(g, /^Permission withdrawn/, 90, 'the withdrawn page');
    } catch (error) {
      // The runner shows the student's page; the guardian's is the one that failed.
      await g.screenshot({path: `${OUT}/guardian_page.png`}).catch(() => {});
      const seen = JSON.stringify((await labels(g).catch(() => [])).slice(0, 30));
      throw new Error(`${error.message} (guardian page ${g.url()}, labels ${seen})`);
    } finally {
      await guardian.close();
    }

    // The student's account is gone, so a new session starts over.
    await student.reload({waitUntil: 'domcontentloaded'});
    await seeLabel(student, /A parent or guardian needs to agree first/, 120,
      'the student asked for a guardian again');
    await refuse(student, /Waiting for your parent or guardian/);
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
  if (ONLY && !name.includes(ONLY)) continue;
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
