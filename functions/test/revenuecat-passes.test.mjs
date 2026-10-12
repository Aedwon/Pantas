import assert from 'node:assert/strict';
import test from 'node:test';
import * as subscriber from '../lib/revenuecatSubscriber.js';

test('AC-4 V2 one-time purchases read status and resolve the verified store product', async () => {
  assert.equal(typeof subscriber.readRevenueCatPurchases, 'function');
  const calls = [];
  const rows = await subscriber.readRevenueCatPurchases('test-project','test-user','test-key',async url => {
    calls.push(url);
    const product = {id:'prod-pass', store_identifier:'pantas_pass_cse_pro', app_id:'app-pantas-test'};
    const purchase = {id:'purc-test', customer_id:'test-user', product_id:'prod-pass',
      purchased_at:1791590400000, status:'refunded', environment:'production',
      store:'play_store', store_purchase_identifier:'GPA.pass-test',
      entitlements:{items:[{lookup_key:'pro',products:{items:[product],next_page:null}}],next_page:null}};
    if (url.includes('/products/')) throw new Error('P1 has no project configuration permission');
    return {ok:true,json:async()=>url.endsWith('/customers/test-user') ? {id:'test-user'} : {items:[purchase],next_page:null}};
  });
  assert.equal(rows[0].status, 'refunded');
  assert.equal(rows[0].productId, 'pantas_pass_cse_pro');
  assert.equal(rows[0].customerId, 'test-user');
  assert.equal(rows[0].transactionId, 'GPA.pass-test');
  assert.equal(calls.length, 2);
});

test('AC-4 an aliased owner resolves to the Firebase UID, while a foreign owner stays foreign', async () => {
  const product = {id:'prod-pass',store_identifier:'pantas_pass_cse_pro',app_id:'app-pantas-test'};
  const p = {product_id:'prod-pass',customer_id:'rc-canonical',purchased_at:1791590400000,
    status:'owned',environment:'production',store:'play_store',store_purchase_identifier:'GPA.alias',
    entitlements:{items:[{lookup_key:'pro',products:{items:[product]}}]}};
  const rows = await subscriber.readRevenueCatPurchases('test-project','firebase-alias','test-key',
    async url=>({ok:true,json:async()=>url.endsWith('/customers/firebase-alias')
      ? {id:'rc-canonical'} : {items:[p,{...p,customer_id:'foreign-owner',store_purchase_identifier:'GPA.foreign'}]}}));
  assert.equal(rows[0].customerId,'firebase-alias');
  assert.equal(rows[1].customerId,'foreign-owner');
});

test('AC-4 one-time purchase read failure is never an empty authoritative answer', async () => {
  assert.equal(typeof subscriber.readRevenueCatPurchases, 'function');
  await assert.rejects(subscriber.readRevenueCatPurchases('test-project','test-user','test-key',
    async()=>({ok:false,status:503})));
});
