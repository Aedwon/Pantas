import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {existsSync, mkdirSync, mkdtempSync, rmSync, writeFileSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {dirname, join, resolve} from 'node:path';
import {fileURLToPath} from 'node:url';
import {test} from 'node:test';

const uploader = fileURLToPath(new URL('./upload_content.mjs', import.meta.url));
const repo = resolve(dirname(uploader), '../..');
for (const mode of ['dry-run', 'out-dir', 'skip-invalid', 'live', 'emulator']) {
  test(`approval gate refuses an unapproved question in ${mode}`, () => {
    const fixture = mkdtempSync(join(tmpdir(), 'upload-gate-'));
    try {
      const root = join(fixture, 'content');
      mkdirSync(join(root, 'questions/math/algebra'), {recursive: true});
      mkdirSync(join(root, 'lessons'), {recursive: true});
      writeFileSync(join(root, 'questions/math/algebra/intro.yaml'), `meta:
  subject: math
  topic: algebra
  subtopic: intro
  exams: [upcat]
questions:
  - id: q-unapproved
    stem: What is one plus one?
    explanation: One plus one is two.
    choices:
      - text: Two
        correct: true
      - text: Three
        correct: false
`);
      // A content root cannot replace the repository's approval gate.
      mkdirSync(join(fixture, 'tool/content'), {recursive: true});
      writeFileSync(join(fixture, 'tool/content/content_gate.dart'), 'void main() {}');
      const exported = join(fixture, 'export.json');
      writeFileSync(exported, JSON.stringify({exam: [], subject: [], topic: [], mockBlueprint: [], diagnosticSet: []}));
      const output = join(fixture, 'output');
      const flags = mode === 'out-dir' ? ['--out-dir', output]
        : mode === 'skip-invalid' ? ['--dry-run', '--skip-invalid']
        : mode === 'live' ? ['--live']
        : mode === 'emulator' ? [] : ['--dry-run'];
      const env = {...process.env};
      delete env.FIRESTORE_EMULATOR_HOST;
      if (mode === 'emulator') env.FIRESTORE_EMULATOR_HOST = '127.0.0.1:1';
      const result = spawnSync(process.execPath, [uploader, '--root', root, '--export', exported, ...flags], {
        cwd: repo, env, encoding: 'utf8',
      });
      const messages = `${result.stdout}${result.stderr}`;
      assert.equal(result.status, 1, messages);
      assert.match(messages, /q-unapproved: not approved/);
      assert.match(messages, /Nothing written: the approval gate failed\./);
      assert.equal(existsSync(output), false);
      assert.doesNotMatch(messages, /lessons:|question sets:/);
    } finally { rmSync(fixture, {recursive: true, force: true}); }
  });
}
