import assert from 'node:assert/strict';
import test from 'node:test';
import {emulatorMailer, expiryLabel, guardianMessage, mailerFor, resendMailer, senderField} from '../lib/guardianMail.js';
import {hashValue, maskEmail, validEmail} from '../lib/guardianConsent.js';

const input = {guardianName: 'Maria', guardianEmail: 'maria@gmail.com',
  link: 'https://app.example.test/guardian?token=abc', expiresAt: Date.parse('2026-11-09T12:00:00+08:00')};

test('the email says exactly what the approved screen says', () => {
  const m = guardianMessage(input);
  assert.equal(m.subject, "Review your child's Pantas account");
  assert.equal(m.to, 'maria@gmail.com');
  for (const line of ["Confirm your child's Pantas account.", 'Hi Maria,',
    'Your child wants to use Pantas, a study app for Philippine exams, and named you as their parent or guardian. We process their account ID and age group, your name and email for this request, and confirmation records and send counters.',
    'Opening the link alone does not confirm.', 'Review and Confirm',
    'The link expires on Nov 9, 2026. Not their parent or guardian? Ignore this email.']) {
    assert.ok(m.text.includes(line), line);
    assert.ok(m.html.includes(line.replace("'", '&#39;')) || m.html.includes(line), line);
  }
  assert.ok(m.text.includes(input.link));
  assert.ok(m.html.includes(`href="${input.link}"`));
  assert.ok(!/[—]/.test(m.text + m.html), 'no em dash');
});

test('names are escaped in the markup', () => {
  const m = guardianMessage({...input, guardianName: '<b>x</b>'});
  assert.ok(!m.html.includes('<script>'));
  assert.ok(!m.html.includes('<b>x</b>'));
});

test('the email never mentions a student name', () => {
  const m = guardianMessage(input);
  assert.ok(!/Juan/.test(m.text + m.html));
  assert.ok(m.text.includes("Confirm your child's Pantas account."));
  assert.ok(!('studentName' in input));
});

test('dates are in Philippine time', () => {
  assert.equal(expiryLabel(Date.parse('2026-11-08T17:00:00Z')), 'Nov 9, 2026');
  assert.equal(expiryLabel(Date.parse('2026-11-08T15:59:00Z')), 'Nov 8, 2026');
});

test('masking, validation and keyed hashing', () => {
  assert.equal(maskEmail('maria@gmail.com'), 'm***@g***.com');
  assert.equal(maskEmail('a.b@mail.example.co.ph'), 'a***@m***.ph');
  assert.ok(validEmail('maria@gmail.com'));
  for (const bad of ['', 'no-at', 'a@b', 'a b@c.com', 'a@c.c', 5, null, 'a@'.padEnd(260, 'x') + '.com']) assert.ok(!validEmail(bad), String(bad));
  const a = hashValue('k1', 'token', 'x');
  assert.match(a, /^[a-f0-9]{64}$/);
  assert.notEqual(a, hashValue('k2', 'token', 'x'));
  assert.notEqual(a, hashValue('k1', 'email', 'x'));
});

test('the emulator mailer prints; mailerFor chooses it only under the emulator flag', async () => {
  const lines = [];
  await emulatorMailer(l => lines.push(l)).send(guardianMessage(input));
  assert.equal(lines.length, 1);
  assert.ok(lines[0].includes(input.link));
  const secrets = {apiKey: () => { throw new Error('read'); }, from: () => { throw new Error('read'); }};
  assert.doesNotThrow(() => mailerFor({FUNCTIONS_EMULATOR: 'true'}, secrets));
  for (const value of [undefined, '', 'false', '1', 'TRUE']) {
    assert.throws(() => mailerFor({FUNCTIONS_EMULATOR: value}, secrets), /read/, `flag ${value}`);
  }
});

test('the Resend mailer posts the message with a bearer key and fails on a refusal', async () => {
  const calls = [];
  const ok = resendMailer('KEY', 'hello@pantas.test', async (url, init) => { calls.push({url, init}); return {ok: true, status: 200}; });
  await ok.send(guardianMessage(input));
  assert.equal(calls[0].url, 'https://api.resend.com/emails');
  assert.equal(calls[0].init.headers.authorization, 'Bearer KEY');
  assert.deepEqual(JSON.parse(calls[0].init.body).to, ['maria@gmail.com']);
  const bad = resendMailer('KEY', 'hello@pantas.test', async () => ({ok: false, status: 422}));
  await assert.rejects(() => bad.send(guardianMessage(input)), /422/);
});

test('outside the emulator a missing key or sender refuses to build a mailer', () => {
  assert.throws(() => mailerFor({}, {apiKey: () => '', from: () => 'a@b.co'}), /not configured/);
  assert.throws(() => mailerFor({}, {apiKey: () => 'k', from: () => ''}), /not configured/);
  assert.doesNotThrow(() => mailerFor({}, {apiKey: () => 'k', from: () => 'a@b.co'}));
});

test('the sender accepts a bare address or "Name <addr>" and never wraps twice', async () => {
  assert.equal(senderField('noreply@pantas.study'), 'Pantas <noreply@pantas.study>');
  assert.equal(senderField(' noreply@pantas.study '), 'Pantas <noreply@pantas.study>');
  assert.equal(senderField('Pantas <noreply@pantas.study>'), 'Pantas <noreply@pantas.study>');
  assert.equal(senderField('Pantas Team <hello@pantas.study>'), 'Pantas Team <hello@pantas.study>');
  for (const from of ['hello@pantas.test', 'Pantas <hello@pantas.test>']) {
    const calls = [];
    await resendMailer('KEY', from, async (url, init) => { calls.push(JSON.parse(init.body)); return {ok: true, status: 200}; })
      .send(guardianMessage(input));
    assert.equal(calls[0].from, 'Pantas <hello@pantas.test>');
  }
});
