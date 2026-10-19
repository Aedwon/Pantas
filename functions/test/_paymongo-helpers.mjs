import {createHmac} from 'node:crypto';
import {handlePaymongoWebhook} from '../lib/paymongoWebhook.js';

export const SECRET = 'whsec_test';
export const ph = iso => Date.parse(iso);

export function signed(body, {now, secret = SECRET, livemode = false, at = now} = {}) {
  const raw = Buffer.from(JSON.stringify(body));
  const t = Math.floor(at / 1000);
  const hex = createHmac('sha256', secret).update(`${t}.`).update(raw).digest('hex');
  return {raw, header: livemode ? `t=${t},te=,li=${hex}` : `t=${t},te=${hex},li=`};
}

export function paidEvent({id = 'evt_1', sessionId = 'cs_1', uid, product, livemode = false, metadata}) {
  return {data: {id, type: 'event', attributes: {type: 'checkout_session.payment.paid', livemode,
    created_at: 1, updated_at: 1, data: {id: sessionId, type: 'checkout_session',
      attributes: {status: 'active', metadata: metadata ?? {uid, product}}}}}};
}

export function resourceEvent({id, type, resource, livemode = false, attributes}) {
  return {data: {id, type: 'event', attributes: {type, livemode, created_at: 1, updated_at: 1,
    data: {id: 'x_1', type: resource, attributes}}}};
}

export function fakeClient(sessions) {
  const calls = [];
  return {calls, getCheckoutSession: async id => {
    calls.push(id);
    const s = sessions[id];
    if (!s) throw new Error('PayMongo down');
    return s;
  }};
}

export const session = ({id = 'cs_1', uid, product, paymentId = 'pay_1', amount, status = 'paid', metadata}) =>
  ({id, metadata: metadata ?? {uid, product}, payments: [{id: paymentId, amount, currency: 'PHP', status}]});

export function fakeAuth() {
  let claims = {other: 'kept'};
  return {getUser: async () => ({customClaims: claims}),
    setCustomUserClaims: async (_, value) => {claims = value;}, current: () => claims};
}

export function send(body, deps, options = {}) {
  const {raw, header} = signed(body, {now: deps.now(), ...options});
  return handlePaymongoWebhook(raw, header, deps);
}
