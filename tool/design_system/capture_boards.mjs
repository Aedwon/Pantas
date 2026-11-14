// Renders the approved screen boards (the exported design handoff) as
// reference images for the key-screen goldens (guardrails layer 3). One image
// per board: web boards at 1440 wide, mobile boards at 390 wide.
//
// Output goes to build/ds-boards/<board>-<web|mobile>.png (gitignored).
// The board folders are read only; nothing is written there.
//
// Playwright is not a dependency of the repo (see capture_reference.mjs for
// the install line). Environment:
//   PW_MODULE   path to the playwright package (default build/pw/node_modules/playwright)
//   PW_CHROME   path to a Chromium or headless-shell binary (default: Playwright's own)
//   HANDOFF     the pantas-handoff folder (default: ../Pantas/web-design/pantas-handoff
//               beside this repo's folder, or the sibling checkout named Pantas)
//   ONLY        comma-separated board names to capture
import {createServer} from 'node:http';
import {createRequire} from 'node:module';
import {existsSync, mkdirSync, readFileSync, writeFileSync} from 'node:fs';
import {dirname, join, resolve} from 'node:path';
import {fileURLToPath, pathToFileURL} from 'node:url';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..', '..');
const require = createRequire(import.meta.url);
const pwPath = process.env.PW_MODULE ?? join(root, 'build/pw/node_modules/playwright');
const {chromium} = require(pwPath);

const handoff = process.env.HANDOFF
  ?? resolve(root, '..', 'Pantas', 'web-design', 'pantas-handoff');
const outDir = join(root, 'build/ds-boards');
mkdirSync(outDir, {recursive: true});

// Each key-screen golden (test/goldens/screens) and the boards that show the
// same screen and state. `web` boards pair with the 1440 golden, `mobile`
// boards with the 390 golden. A golden with an empty list has no board.
export const boardMap = {
  home: {web: ['HM_BeforeAssessment'], mobile: ['HE_BeforeAssessment']},
  assessment_question: {web: ['AS_Question'], mobile: ['AS_Question']},
  assessment_results: {web: ['AS_Results'], mobile: ['AS_Results']},
  lesson_reader: {web: ['RD_Real'], mobile: ['RD_Real']},
  mock_results: {web: ['MK_ResultsFree'], mobile: ['MK_ResultsFree']},
  mock_session: {web: ['W_Mock'], mobile: ['MK_Paper']},
  mock_setup: {web: ['MK_Setup'], mobile: []},
  onboarding_age: {web: ['OB_Age'], mobile: ['O_Age']},
  onboarding_consent: {web: ['OB_Terms'], mobile: ['O_Consent']},
  onboarding_date: {web: ['OB_DateKnown'], mobile: ['O_DateKnown']},
  onboarding_name: {web: ['OB_Name'], mobile: ['O_Name']},
  onboarding_picker: {web: ['OB_Picker'], mobile: ['O_Picker']},
  onboarding_study_days: {web: ['OB_Days'], mobile: ['O_Days']},
  performance: {web: ['PF_Subjects'], mobile: ['DT_TopicsA']},
  plan: {web: ['PL_Plan'], mobile: ['DP_PlanA']},
  plan_day: {web: ['PL_Day'], mobile: ['DP_Day']},
  pro: {web: ['ST_ProCSE'], mobile: ['ST_ProCSE']},
  questions_unavailable: {web: [], mobile: []},
  quiz_question_picking: {web: ['W_Question'], mobile: ['QV_Answer']},
  quiz_question_revealed: {web: ['W_QMiss', 'W_QRight'], mobile: ['QV_MissFree']},
  quiz_tab: {web: ['W_QuizTab'], mobile: ['QZ_Tab']},
  session_end: {web: ['W_SessionEnd'], mobile: ['QV_EndPro']},
  settings_about: {web: ['ST_About'], mobile: ['ST_About']},
  settings_account: {web: ['ST_Account'], mobile: ['ST_Account']},
  settings_appearance: {web: ['ST_Appearance'], mobile: ['ST_Appearance']},
  settings_backup: {web: ['ST_BackupDetails'], mobile: ['ST_BackupStates']},
  settings_exam: {web: ['ST_Exam'], mobile: ['ST_Exam']},
  settings_home: {web: ['W_Settings'], mobile: ['ST_Root']},
  study_list: {web: ['W_Study'], mobile: ['ST_Map']},
};

if (process.argv.includes('--map')) {
  console.log(JSON.stringify(boardMap, null, 2));
  process.exit(0);
}

const only = process.env.ONLY ? new Set(process.env.ONLY.split(',')) : null;
const jobs = [];
for (const kind of ['web', 'mobile']) {
  const names = new Set(Object.values(boardMap).flatMap((m) => m[kind]));
  const canvas = JSON.parse(readFileSync(join(handoff, kind, 'project', 'canvas.json'), 'utf8'));
  for (const name of [...names].sort()) {
    if (only && !only.has(name)) continue;
    const size = canvas.boards[`${name}.dc.html`] ?? {w: kind === 'web' ? 1440 : 390, h: kind === 'web' ? 900 : 844};
    jobs.push({kind, name, w: size.w, h: size.h});
  }
}

// The boards pull fonts from Google and the web boards pull the shared
// stylesheet by a /_blob/ address. Serve the local copies instead, so a run
// needs no network.
const fontsDir = join(root, 'assets/fonts');
const faces = {400: 'Regular', 500: 'Medium', 600: 'SemiBold', 700: 'Bold', 800: 'Bold'};
const fontCss = Object.entries(faces).map(([w, file]) =>
  `@font-face{font-family:'Geist';font-weight:${w};src:url('${pathToFileURL(join(fontsDir, `Geist-${file}.ttf`))}')}`,
).join('\n') + `\n@font-face{font-family:'Source Serif 4';font-weight:200 900;src:url('${pathToFileURL(join(fontsDir, 'SourceSerif4-Variable.ttf'))}')}`;
const sharedCss = readFileSync(join(handoff, 'web', 'shared', 'pantas.css'), 'utf8');

// The boards fetch their sibling parts (the sidebar) with fetch(), which a
// file: page cannot do. Serve the folders read-only on loopback instead.
const types = {'.html': 'text/html', '.js': 'text/javascript', '.css': 'text/css', '.json': 'application/json'};
const server = createServer((req, res) => {
  const path = decodeURIComponent((req.url ?? '/').split('?')[0]);
  if (path.startsWith('/_blob/')) {
    res.writeHead(200, {'content-type': 'text/css'});
    res.end(sharedCss);
    return;
  }
  const file = resolve(handoff, `.${path}`);
  if (!file.startsWith(handoff) || !existsSync(file)) {
    res.writeHead(404);
    res.end();
    return;
  }
  const ext = file.slice(file.lastIndexOf('.'));
  res.writeHead(200, {'content-type': types[ext] ?? 'application/octet-stream'});
  res.end(readFileSync(file));
});
await new Promise((done) => server.listen(0, '127.0.0.1', done));
const base = `http://127.0.0.1:${server.address().port}`;

const browser = await chromium.launch({
  executablePath: process.env.PW_CHROME || undefined,
  // No macOS login-keychain prompt on a local run (Nov 14 process improvement).
  args: ['--use-mock-keychain', '--password-store=basic'],
});
const ok = [];
const failed = [];
try {
  for (const {kind, name, w, h} of jobs) {
    const file = join(handoff, kind, 'project', `${name}.dc.html`);
    if (!existsSync(file)) {
      failed.push(`${kind}/${name}: no such board`);
      continue;
    }
    const context = await browser.newContext({
      viewport: {width: w, height: h},
      deviceScaleFactor: 1,
      reducedMotion: 'reduce',
    });
    await context.route((url) => url.origin !== base && url.protocol !== 'file:', (r) => r.abort());
    await context.route(/fonts\.googleapis\.com/, (r) =>
      r.fulfill({contentType: 'text/css', body: fontCss}));
    const page = await context.newPage();
    try {
      await page.goto(`${base}/${kind}/project/${name}.dc.html`);
      await page.waitForTimeout(500);
      await page.evaluate(() => document.fonts.ready);
      await page.addStyleTag({content: '*{animation:none!important;transition:none!important;caret-color:transparent!important}'});
      await page.screenshot({path: join(outDir, `${name}-${kind}.png`)});
      ok.push(`${kind}/${name}`);
    } catch (e) {
      failed.push(`${kind}/${name}: ${e.message.split('\n')[0]}`);
    } finally {
      await context.close();
    }
  }
} finally {
  await browser.close();
  server.close();
}
writeFileSync(join(outDir, 'map.json'), JSON.stringify(boardMap, null, 2));
console.log(`captured ${ok.length} boards to ${outDir}`);
if (failed.length) {
  console.log(`failed ${failed.length}:\n  ${failed.join('\n  ')}`);
  process.exitCode = 1;
}
