import assert from 'node:assert/strict';
import {mkdtempSync, mkdirSync, writeFileSync, rmSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
import {test} from 'node:test';
import {checkIllustrationFiles, resolveLessonIllustrations} from './lesson_illustrations.mjs';

test('server content carries SVG and PNG bytes in marker order', () => {
  const root = mkdtempSync(join(tmpdir(), 'b9-upload-'));
  try {
    const dir = join(root, 'math/topic/lesson'); mkdirSync(dir, {recursive:true});
    writeFileSync(join(dir, '02-old.png'), Buffer.from([137,80,78,71]));
    writeFileSync(join(dir, '01-new.svg'), '<svg width="10" height="10"/>');
    const result = resolveLessonIllustrations('<!-- ILLUSTRATION: First -->\n<!-- ILLUSTRATION: Second -->', 'math/topic/lesson.md', root);
    const images = [...result.matchAll(/<!-- IMAGE: (.*?) -->/g)].map(m => JSON.parse(m[1]));
    assert.equal(images.length, 2);
    assert.match(images[0].asset.url, /^data:image\/svg\+xml;base64,/);
    assert.match(images[1].asset.url, /^data:image\/png;base64,/);
    assert.equal(images[0].alt, 'First');
    assert.equal(Buffer.from(images[0].asset.url.split(',')[1], 'base64').toString(), '<svg width="10" height="10"/>');
    writeFileSync(join(dir, '01-duplicate.svg'), '<svg/>');
    assert.throws(() => resolveLessonIllustrations('<!-- ILLUSTRATION: First -->', 'math/topic/lesson.md', root), /duplicate/i);
  } finally { rmSync(root, {recursive:true, force:true}); }
});
test('rejects unsafe lesson paths', () => {
  assert.throws(() => resolveLessonIllustrations('', '../lesson.md', '/tmp'), /path/i);
});
test('preserves remote PNG slots while replacing a later slot with local SVG', () => {
  const root = mkdtempSync(join(tmpdir(), 'b9-remote-'));
  try {
    const dir = join(root, 'math/topic/lesson'); mkdirSync(dir, {recursive:true});
    writeFileSync(join(dir, '04-new.svg'), '<svg/>');
    writeFileSync(join(root, 'assets.json'), JSON.stringify({
      'math/topic/lesson#2': {url:'https://example.com/old.png', alt:'Remote alt', creditKey:'old'},
      'math/topic/lesson#4': {url:'https://example.com/replaced.png', alt:'Replacement alt', creditKey:'old'},
    }));
    const result = resolveLessonIllustrations('<!-- ILLUSTRATION: First -->\n<!-- ILLUSTRATION: Second -->', 'math/topic/lesson.md', root, {old:'Original artist'});
    const images = [...result.matchAll(/<!-- IMAGE: (.*?) -->/g)].map(m => JSON.parse(m[1]));
    assert.equal(images[0].asset.url, 'https://example.com/old.png');
    assert.equal(images[0].alt, 'Remote alt');
    assert.equal(images[0].asset.credit, 'Original artist');
    assert.match(images[1].asset.url, /^data:image\/svg\+xml/);
    assert.equal(images[1].alt, 'Replacement alt');
    assert.equal(images[1].asset.credit, 'Original artist');
  } finally { rmSync(root, {recursive:true, force:true}); }
});
test('rejects symlinked subject ancestors', async () => {
  const {symlinkSync} = await import('node:fs');
  const root = mkdtempSync(join(tmpdir(), 'b9-link-'));
  try {
    mkdirSync(join(root, 'outside/topic/lesson'), {recursive:true});
    writeFileSync(join(root, 'outside/topic/lesson/01-a.svg'), '<svg/>');
    symlinkSync(join(root, 'outside'), join(root, 'math'));
    assert.throws(() => resolveLessonIllustrations('<!-- ILLUSTRATION: x -->', 'math/topic/lesson.md', root), /unsafe/i);
  } finally { rmSync(root, {recursive:true, force:true}); }
});

function lessonDir(root) {
  const dir = join(root, 'math/topic/lesson'); mkdirSync(dir, {recursive: true});
  return dir;
}
for (const name of ['1-short-number.svg', '01-Upper-Case.svg', '01-upper-extension.SVG', '01-photo.jpg', '01_underscore.svg', '00-zero.svg']) {
  test(`misnamed figure file fails with its path and the rule: ${name}`, () => {
    const root = mkdtempSync(join(tmpdir(), 'b9-name-'));
    try {
      const dir = lessonDir(root);
      writeFileSync(join(dir, '01-good.svg'), '<svg/>');
      writeFileSync(join(dir, name), '<svg/>');
      assert.throws(
        () => resolveLessonIllustrations('<!-- ILLUSTRATION: One -->', 'math/topic/lesson.md', root),
        error => error.message.includes(join(dir, name)) && error.message.includes('NN-slug'),
      );
    } finally { rmSync(root, {recursive: true, force: true}); }
  });
}
test('a figure file no marker uses fails with its path', () => {
  const root = mkdtempSync(join(tmpdir(), 'b9-unused-'));
  try {
    const dir = lessonDir(root);
    writeFileSync(join(dir, '01-a.svg'), '<svg/>');
    writeFileSync(join(dir, '02-b.svg'), '<svg/>');
    assert.throws(
      () => resolveLessonIllustrations('<!-- ILLUSTRATION: Only one -->', 'math/topic/lesson.md', root),
      error => error.message.includes(join(dir, '02-b.svg')) && /no ILLUSTRATION marker/.test(error.message),
    );
    assert.throws(
      () => resolveLessonIllustrations('No figures here.', 'math/topic/lesson.md', root),
      error => error.message.includes(join(dir, '01-a.svg')),
    );
  } finally { rmSync(root, {recursive: true, force: true}); }
});
test('the whole illustration tree is checked for names at the wrong depth and for lessons that do not exist', () => {
  const root = mkdtempSync(join(tmpdir(), 'b9-tree-'));
  try {
    mkdirSync(join(root, 'math/topic/lesson/extra'), {recursive: true});
    mkdirSync(join(root, 'math/topic/renamed'), {recursive: true});
    writeFileSync(join(root, 'math/topic/lesson/01-good.svg'), '<svg/>');
    writeFileSync(join(root, 'math/topic/01-too-shallow.svg'), '<svg/>');
    writeFileSync(join(root, 'math/topic/lesson/extra/01-too-deep.svg'), '<svg/>');
    writeFileSync(join(root, 'math/topic/renamed/01-a.svg'), '<svg/>');
    writeFileSync(join(root, 'math/topic/lesson/notes.txt'), 'not a figure');
    const problems = checkIllustrationFiles(root, new Set(['math/topic/lesson']));
    assert.equal(problems.length, 3);
    assert.ok(problems.some(p => p.includes(join(root, 'math/topic/01-too-shallow.svg')) && p.includes('NN-slug')));
    assert.ok(problems.some(p => p.includes(join(root, 'math/topic/lesson/extra/01-too-deep.svg')) && p.includes('NN-slug')));
    assert.ok(problems.some(p => p.includes(join(root, 'math/topic/renamed/01-a.svg')) && /no lesson/.test(p)));
  } finally { rmSync(root, {recursive: true, force: true}); }
});
