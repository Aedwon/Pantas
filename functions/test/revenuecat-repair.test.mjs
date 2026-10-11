import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import test from 'node:test';
import {repairClaims} from '../lib/revenuecatClaims.js';

test('finding 3 hourly repair reads zero entitlement documents in an unchanged population', async()=>{
  const population = Array.from({length:50},()=>({id:'entitlement',get:field=>
    ({claimsPending:false,claimsVersion:1,version:1})[field]}));
  let documentReads = 0;
  function query(rows) {
    return {
      where:(field,op,value)=>query(rows.filter(row=>row.get(field)===value)),
      orderBy:()=>query(rows),limit:count=>query(rows.slice(0,count)),
      get:async()=>{documentReads += rows.length;return {docs:rows,size:rows.length};},
    };
  }
  await repairClaims({collectionGroup:()=>query(population)}, {
    getUser:async()=>{throw Error('unchanged accounts must not read Auth');},
    setCustomUserClaims:async()=>{throw Error('unchanged accounts must not copy');},
  });
  assert.equal(documentReads,0);
});

test('finding 3 repair queries have single-field collection-group overrides',()=>{
  const config=JSON.parse(readFileSync(new URL('../../firestore.indexes.json',import.meta.url)));
  for(const field of ['claimsPending','updatedAt']) {
    const overrides=config.fieldOverrides.filter(override=>
      override.collectionGroup==='server' && override.fieldPath===field);
    assert.equal(overrides.length,1,field);
    assert.deepEqual(overrides[0].indexes,[
      {order:'ASCENDING',queryScope:'COLLECTION'},
      {order:'ASCENDING',queryScope:'COLLECTION_GROUP'},
    ],field);
  }
});


test('finding 4 TTL is declared on the actual event child group and rate-limit group',()=>{
  const config=JSON.parse(readFileSync(new URL('../../firestore.indexes.json',import.meta.url)));
  for(const group of ['users','webhookRateLimits']) {
    assert.ok(config.fieldOverrides?.some(field=>field.collectionGroup===group &&
      field.fieldPath==='expireAt' && field.ttl===true),group);
  }
});
