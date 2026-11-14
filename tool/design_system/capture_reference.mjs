// Captures the design system's own previews as reference images for the
// golden audit (guardrails layer 3). One image per component per theme,
// not one per state: it screenshots the light and dark panels of each
// design/system/components/<Name>/preview.html at 1x.
//
// Output goes to build/ds-reference/ (gitignored). Nothing here is committed.
//
// Playwright is not a dependency of the repo. Install it outside the tracked
// tree, then point this script at it:
//   mkdir -p build/pw && (cd build/pw && npm init -y && npm i --no-save playwright@1.49.1)
//   node tool/design_system/capture_reference.mjs
//
// Environment:
//   PW_MODULE   path to the playwright package (default build/pw/node_modules/playwright)
//   PW_CHROME   path to a Chromium or headless-shell binary (default: Playwright's own)
//   ONLY        comma-separated component names to capture
import {createRequire} from 'node:module';
import {existsSync, mkdirSync, readdirSync, readFileSync} from 'node:fs';
import {dirname, join, resolve} from 'node:path';
import {fileURLToPath, pathToFileURL} from 'node:url';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..', '..');
const require = createRequire(import.meta.url);
const pwPath = process.env.PW_MODULE ?? join(root, 'build/pw/node_modules/playwright');
const {chromium} = require(pwPath);

const componentsDir = join(root, 'design/system/components');
const outDir = join(root, 'build/ds-reference');
mkdirSync(outDir, {recursive: true});

const only = process.env.ONLY ? new Set(process.env.ONLY.split(',')) : null;
const names = readdirSync(componentsDir, {withFileTypes: true})
  .filter((d) => d.isDirectory() && existsSync(join(componentsDir, d.name, 'preview.html')))
  .map((d) => d.name)
  .filter((n) => !only || only.has(n))
  .sort();

// The previews pull fonts from Google. Serve the bundled font files instead,
// so a run needs no network and renders the same type the app ships.
const fontsDir = join(root, 'assets/fonts');
const fontCss = [400, 500, 600, 700].map((w) => {
  const file = {400: 'Regular', 500: 'Medium', 600: 'SemiBold', 700: 'Bold'}[w];
  return `@font-face{font-family:'Geist';font-weight:${w};src:url('${pathToFileURL(join(fontsDir, `Geist-${file}.ttf`))}')}`;
}).join('\n') + `\n@font-face{font-family:'Source Serif 4';font-weight:200 900;src:url('${pathToFileURL(join(fontsDir, 'SourceSerif4-Variable.ttf'))}')}`;

// The vendored system ships no tokens.css (its page generates one). Build the
// same thing from tokens.json: colors and shadows per theme, every other token
// under :root, the two font families. Type classes come from bundle.css.
const tokens = JSON.parse(readFileSync(join(root, 'design/system/tokens.json'), 'utf8'));
const ref = (v, theme) => {
  const x = typeof v === 'object' ? (v[theme] ?? v.light) : v;
  return String(x).replace(/\{([^}]+)\}/g, 'var(--$1)');
};
const themed = [...tokens.color.tokens, ...tokens.shadow.tokens];
const plain = ['spacing', 'radius', 'border', 'layout', 'size', 'easing', 'duration', 'zIndex', 'opacity']
  .flatMap((k) => tokens[k].tokens);
const decl = (list, theme) => list.map((t) => `--${t.name}:${ref(t.value, theme)};`).join('');
const tokensCss =
  `:root,[data-theme="light"]{${decl(themed, 'light')}color-scheme:light}` +
  `[data-theme="dark"]{${decl(themed, 'dark')}color-scheme:dark}` +
  `:root{${decl(plain, 'light')}--font-sans:${tokens.type.families.sans};--font-serif:${tokens.type.families.serif}}`;
const bundleCss = readFileSync(join(componentsDir, 'bundle.css'), 'utf8');

const browser = await chromium.launch({
  executablePath: process.env.PW_CHROME || undefined,
  // No macOS login-keychain prompt on a local run (Nov 14 process improvement).
  args: ['--use-mock-keychain', '--password-store=basic'],
});
const ok = [];
const failed = [];
try {
  const context = await browser.newContext({
    viewport: {width: 1000, height: 900},
    deviceScaleFactor: 1,
    reducedMotion: 'reduce',
  });
  // Playwright runs the last route registered first, so abort everything
  // else before the font route, or the abort would win.
  await context.route(/^(?!file:)/, (r) => r.abort());
  await context.route(/fonts\.googleapis\.com/, (r) =>
    r.fulfill({contentType: 'text/css', body: fontCss}));
  for (const name of names) {
    const page = await context.newPage();
    try {
      await page.goto(pathToFileURL(join(componentsDir, name, 'preview.html')).href);
      await page.addStyleTag({content: tokensCss});
      await page.addStyleTag({content: bundleCss});
      await page.evaluate(() => document.fonts.ready);
      await page.addStyleTag({content: '*{animation:none!important;transition:none!important;caret-color:transparent!important}'});
      for (const theme of ['light', 'dark']) {
        const panel = page.locator(`section.pv-p[data-theme=${theme}]`).first();
        if ((await panel.count()) === 0) throw new Error(`no ${theme} panel`);
        await panel.screenshot({path: join(outDir, `${name}-${theme}.png`)});
      }
      ok.push(name);
    } catch (e) {
      failed.push(`${name}: ${e.message.split('\n')[0]}`);
    } finally {
      await page.close();
    }
  }
} finally {
  await browser.close();
}
console.log(`captured ${ok.length} components (${ok.length * 2} images) to ${outDir}`);
if (failed.length) {
  console.log(`failed ${failed.length}:\n  ${failed.join('\n  ')}`);
  process.exitCode = 1;
}
