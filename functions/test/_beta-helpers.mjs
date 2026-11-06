import assert from 'node:assert/strict';
export const uid = 'reward-tester';
export const feedbackId = 'A'.repeat(20);
export const request = (data = {}) => ({auth: {uid, token: {email: 'tester@example.com', email_verified: true,
  firebase: {sign_in_provider: 'google.com'}}}, app: {appId: 'test'}, data});
// Small transactional Firestore double. Reject reads after writes, like production Firestore.
export function fixture(at = Date.parse('2026-11-15T12:00:00+08:00')) {
  const rows = new Map([['betaApplications/test', {email: 'tester@example.com', selected: true}]]);
  const doc = path => ({path, id: path.split('/').at(-1)});
  const snap = ref => ({ref, id: ref.id, exists: rows.has(ref.path), data: () => rows.get(ref.path), get: key => rows.get(ref.path)?.[key]});
  const collection = path => ({path, where: (field, op, value) => ({get: async () => ({docs: [...rows].filter(([p,r]) => p.startsWith(path+'/') && r[field] === value).map(([p]) => snap(doc(p)))})})});
  const db = {doc, collection, runTransaction: async fn => {
    const writes = [];
    const tx = {get: async ref => {
      assert.equal(writes.length, 0, 'all transaction reads must precede writes');
      return ref.id ? snap(ref) : {docs: [...rows.keys()].filter(p => p.startsWith(ref.path+'/') && p.split('/').length === ref.path.split('/').length+1).map(p => snap(doc(p)))};
    }, set: (ref, value, options) => {writes.push(() => rows.set(ref.path, options?.merge ? {...rows.get(ref.path), ...value} : value));}};
    const result = await fn(tx); writes.forEach(f => f()); return result;
  }};
  return {db, rows, now: () => at, allow: async () => true,
    metadata: async () => ({contentType:'image/png', size:'10'})};
}
