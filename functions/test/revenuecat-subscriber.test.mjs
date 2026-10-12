import assert from 'node:assert/strict';
import test from 'node:test';
let subscriber;
try {subscriber = await import('../lib/revenuecatSubscriber.js');} catch (e) {if(e.code !== 'ERR_MODULE_NOT_FOUND') throw e;}
const subscription = {product_id:'prod-test', gives_access:true, ends_at:2000000000000, environment:'production', store:'play_store', entitlements:{items:[{id:'ent-pro', lookup_key:'pro', products:{items:[{id:'prod-test',store_identifier:'pantas_pro_monthly',app_id:'app-pantas-test'}],next_page:null}}],next_page:null}};
test('AC-3 v2 subscription pages map store products and retained facts without using event expiry', async () => {
  assert.equal(typeof subscriber?.readRevenueCatCustomer, 'function');
  const calls = [];
  const rows = await subscriber.readRevenueCatCustomer('test-project','test-user','test-key', async (url, options) => {
    calls.push(url); assert.equal(options.headers.Authorization,'Bearer test-key');
    return {ok:true,json:async()=>({items:[subscription],next_page:calls.length === 1 ? '/v2/projects/test-project/customers/test-user/subscriptions?starting_after=next' : null})};
  });
  assert.equal(rows.length, 2); assert.equal(rows[0].productId,'pantas_pro_monthly');
  assert.equal(rows[0].appId,'app-pantas-test'); assert.deepEqual(rows[0].entitlementIds,['pro']);
});
test('AC-3 a RevenueCat outage throws and never becomes an inactive answer', async () => {
  assert.equal(typeof subscriber?.readRevenueCatCustomer, 'function');
  await assert.rejects(subscriber.readRevenueCatCustomer('test-project','test-user','test-key',async()=>({ok:false,status:503})));
});
test('AC-7 v2 promotional subscriptions use the named entitlement, never a fabricated product', async () => {
  assert.equal(typeof subscriber?.readRevenueCatCustomer, 'function');
  const rows = await subscriber.readRevenueCatCustomer('test-project','test-user','test-key',async()=>({ok:true,json:async()=>({items:[{...subscription,product_id:null,store:'promotional',entitlements:{items:[{lookup_key:'promo_student'}]}}],next_page:null})}));
  assert.equal(rows[0].productId,null); assert.equal(rows[0].store,'promotional');
  assert.deepEqual(rows[0].entitlementIds,['promo_student']);
});
test('AC-3 two subscriptions can share an entitlement product page', async () => {
  const withPage = {...subscription, entitlements:{items:[{lookup_key:'pro',products:{items:[],next_page:'/v2/projects/test-project/entitlements/pro/products?starting_after=first'}}]}};
  const rows = await subscriber.readRevenueCatCustomer('test-project','test-user','test-key',async url=>({ok:true,json:async()=>url.includes('/subscriptions') ? {items:[withPage,withPage],next_page:null} : {items:subscription.entitlements.items[0].products.items,next_page:null}}));
  assert.equal(rows.length,2);
});
