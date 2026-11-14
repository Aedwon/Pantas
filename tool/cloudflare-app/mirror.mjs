// Copies the files of a Firebase Hosting site's live release into a folder, byte for byte, so the
// Worker serves exactly what Firebase serves. Usage:
//   node tool/cloudflare-app/mirror.mjs <hosting site id> <project id> <out dir>
// Needs `gcloud auth print-access-token` for an account that can read the site.
import {execFileSync} from 'node:child_process';
import {mkdirSync, writeFileSync} from 'node:fs';
import {dirname, join} from 'node:path';

const [site, project, out] = process.argv.slice(2);
if (!site || !project || !out) { console.error('usage: mirror.mjs <site> <project> <out dir>'); process.exit(2); }
const token = execFileSync('gcloud', ['auth', 'print-access-token']).toString().trim();
const api = async path => {
  const response = await fetch(`https://firebasehosting.googleapis.com/v1beta1/${path}`, {headers: {Authorization: `Bearer ${token}`, 'x-goog-user-project': project}});
  if (!response.ok) throw new Error(`${path}: ${response.status} ${await response.text()}`);
  return response.json();
};

const {releases} = await api(`sites/${site}/releases?pageSize=1`);
const version = releases[0].version.name;
console.log(`live release ${releases[0].name.split('/').pop()}, version ${version.split('/').pop()}`);
const files = [];
let page = '';
do {
  const result = await api(`${version}/files?pageSize=1000${page ? `&pageToken=${page}` : ''}`);
  files.push(...(result.files ?? []));
  page = result.nextPageToken ?? '';
} while (page);

let bytes = 0;
// compare.mjs then checks every file's bytes against Firebase.
for (const {path} of files) {
  const response = await fetch(`https://${site}.web.app${path}`, {headers: {'accept-encoding': 'identity'}});
  if (!response.ok) throw new Error(`${path}: ${response.status}`);
  const body = Buffer.from(await response.arrayBuffer());
  const target = join(out, path);
  mkdirSync(dirname(target), {recursive: true});
  writeFileSync(target, body);
  bytes += body.length;
}
console.log(`${files.length} files, ${(bytes / 1048576).toFixed(1)} MiB, into ${out}`);
