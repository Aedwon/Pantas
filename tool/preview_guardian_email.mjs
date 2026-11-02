// Writes the guardian email as an HTML file so it can be opened and captured.
// Local use only: nothing here is imported by the app or the deployed functions.
//
//   npm --prefix functions run build
//   node tool/preview_guardian_email.mjs <out.html> [guardianName]
import {writeFileSync} from 'node:fs';
import {guardianMessage} from '../functions/lib/guardianMail.js';

const [out, guardianName = 'Maria'] = process.argv.slice(2);
if (!out) {
  console.error('Usage: node tool/preview_guardian_email.mjs <out.html> [guardianName]');
  process.exit(2);
}
const message = guardianMessage({
  guardianName, guardianEmail: 'maria@gmail.com',
  link: 'http://localhost/guardian?token=preview',
  expiresAt: Date.parse('2026-11-09T12:00:00+08:00'),
});
writeFileSync(out, message.html);
console.log(`Wrote ${out}. Subject: ${message.subject}`);
