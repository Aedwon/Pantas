#!/usr/bin/env node
// Re-delivers a paid checkout the webhook never granted (docs/OPERATIONS.md, "Paid but no Pro").
// node tool/payments/redeliver_payment.mjs <project> <checkout session id>
// It reads the session from PayMongo with the project's secret key, builds the
// checkout_session.payment.paid event the webhook expects, signs it with the webhook secret as PayMongo
// does, and sends it to the project's paymongoWebhook. The webhook reads the session again and grants
// nothing it cannot verify, and a payment already granted changes nothing, so a retry is safe.
// Both secrets come from Secret Manager at run time (needs `gcloud auth login`). Neither is printed.
import {execFileSync} from 'node:child_process';
import {createHmac} from 'node:crypto';
import {pathToFileURL} from 'node:url';

const PROJECT = /^pantas-(prod|staging)$/;
const SESSION = /^cs_[A-Za-z0-9_]+$/;

export function readSecretsFromGcloud(project, run = (command, args, options) => execFileSync(command, args, options)) {
  let text;
  try {
    text = run('gcloud', ['secrets', 'versions', 'access', 'latest', '--secret', 'PANTAS_PAYMENT_SECRETS',
      '--project', project], {encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore']});
  } catch { throw new Error('Could not read the payment secrets. Run `gcloud auth login` and check access.'); }
  // A parse error can quote part of the payload, so it is never kept or printed.
  try { return JSON.parse(text); }
  catch { throw new Error('The payment secrets could not be read as JSON. Check the secret version.'); }
}

const obj = value => value !== null && typeof value === 'object' && !Array.isArray(value) ? value : {};

export async function redeliverPayment({project, sessionId, fetchImpl = fetch, now = Date.now,
  readSecrets = readSecretsFromGcloud, log = console.log}) {
  if (!PROJECT.test(project ?? '') || !SESSION.test(sessionId ?? '')) {
    throw new Error('Check the arguments: <pantas-prod|pantas-staging> <checkout session id, cs_...>.');
  }
  const secrets = readSecrets(project);
  const key = secrets.PAYMONGO_SECRET_KEY, signing = secrets.PAYMONGO_WEBHOOK_SECRET;
  if (typeof key !== 'string' || typeof signing !== 'string' || !key || !signing) {
    throw new Error('The payment secrets are missing PAYMONGO_SECRET_KEY or PAYMONGO_WEBHOOK_SECRET.');
  }
  const livemode = key.startsWith('sk_live_');
  const read = await fetchImpl(`https://api.paymongo.com/v1/checkout_sessions/${sessionId}`, {method: 'GET',
    headers: {Authorization: `Basic ${Buffer.from(`${key}:`).toString('base64')}`, 'Content-Type': 'application/json'}});
  if (!read.ok) throw new Error(`PayMongo session read failed: HTTP ${read.status}`);
  const data = obj(obj(await read.json()).data);
  if (data.id !== sessionId) throw new Error('PayMongo returned a different checkout session.');
  const attributes = obj(data.attributes);
  const nested = obj(obj(attributes.payment_intent).attributes).payments;
  const payments = Array.isArray(attributes.payments) && attributes.payments.length > 0 ? attributes.payments
    : Array.isArray(nested) ? nested : [];
  const paid = payments.filter(p => obj(obj(p).attributes).status === 'paid');
  if (paid.length === 0) throw new Error('The session has no paid payment. Nothing was sent.');
  const metadata = {};
  for (const [k, v] of Object.entries(obj(attributes.metadata))) if (typeof v === 'string') metadata[k] = v;
  const body = JSON.stringify({data: {id: `evt_redeliver_${sessionId}`, type: 'event', attributes: {
    type: 'checkout_session.payment.paid', livemode,
    data: {id: sessionId, type: 'checkout_session', attributes: {metadata}}}}});
  const t = Math.floor(now() / 1000);
  const mac = createHmac('sha256', signing).update(`${t}.${body}`).digest('hex');
  const signature = livemode ? `t=${t},te=,li=${mac}` : `t=${t},te=${mac},li=`;
  const response = await fetchImpl(`https://asia-southeast1-${project}.cloudfunctions.net/paymongoWebhook`,
    {method: 'POST', headers: {'Content-Type': 'application/json', 'Paymongo-Signature': signature}, body});
  log(`${sessionId} (${paid[0].id}): HTTP ${response.status}`, response.status === 200 ?
    'delivered; confirm the grant in Firestore' : 'request failed, see the function log');
  return response.status;
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const [project, sessionId] = process.argv.slice(2);
  try { process.exitCode = (await redeliverPayment({project, sessionId})) === 200 ? 0 : 1; }
  catch (error) { console.error(error.message); process.exitCode = 2; }
}
