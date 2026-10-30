// Emulator-only accounts. Runs the actual server trial grant and claim-copy path.
import {createRequire} from 'node:module';
import {resolve} from 'node:path';
import {networkInterfaces} from 'node:os';
import {writeFileSync} from 'node:fs';
const require = createRequire(resolve('functions/package.json'));
const project = 'demo-pantas-local';
for (const [key, port] of [['FIRESTORE_EMULATOR_HOST', 8080], ['FIREBASE_AUTH_EMULATOR_HOST', 9099]]) {
  const host = process.env[key]?.split(':')[0];
  const addresses = Object.values(networkInterfaces()).flat().map(row => row?.address);
  if (!addresses.includes(host) || process.env[key] !== `${host}:${port}`) throw Error(`Unsafe ${key}`);
}
const {initializeApp} = require('firebase-admin/app');
const {getAuth} = require('firebase-admin/auth');
const {getFirestore} = require('firebase-admin/firestore');
initializeApp({projectId: project});
const auth = getAuth();
const password = 'Local-visual-check-123!';
for (const name of ['free', 'pro']) {
  await auth.createUser({uid: `local-${name}`, email: `${name}@pantas.local`, password, emailVerified: true});
}
process.env.TRIAL_IDENTITY_HMAC_KEY = 'local-emulator-only-not-a-secret';
const {startTrial} = require(resolve('functions/lib/webTrial.js'));
await startTrial({uid: 'local-pro', token: {email: 'pro@pantas.local', email_verified: true,
  firebase: {sign_in_provider: 'password', identities: {password: ['pro@pantas.local']}}}},
{db: getFirestore(), auth});
const pro = await auth.getUser('local-pro');
if (!pro.customClaims?.pro) throw Error('Server grant did not copy Pro claims');
writeFileSync('build/local-web/logins.txt',
  `EMULATOR ONLY. Reset each run. Pro uses the server's seven-day trial grant.\nFree: free@pantas.local\nPro: pro@pantas.local\nPassword (both): ${password}\n`, {mode: 0o600});
console.log('Created Free and Pro emulator accounts. Server grant and claims confirmed.');
