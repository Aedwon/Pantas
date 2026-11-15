import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {lessonCredit} from '../lib/_lessonCredit.js';
const cases=JSON.parse(readFileSync(new URL('../../test/fixtures/content/lesson_credit_cases.json',import.meta.url),'utf8'));
for(const c of cases)test(c.name,()=>{
 const reads=lessonCredit(c.retired,new Map(Object.entries(c.reads)),(a,b)=>a-b);
 assert.deepEqual(Object.fromEntries(c.active.filter(id=>reads.has(id)).map(id=>[id,reads.get(id)])),c.expectedReads);
 const excluded=lessonCredit(c.retired,new Map(c.excluded.map(id=>[id,true])),()=>0);
 assert.deepEqual(c.active.filter(id=>excluded.has(id)).sort(),c.expectedExcluded.sort());
});
