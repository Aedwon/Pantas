import assert from 'node:assert/strict';
import test from 'node:test';
import {createRequire} from 'node:module';
createRequire(import.meta.url)('../src/generated/pantas_core.js');
test('shared Dart insights distinguish absent observations from measured results',()=>{
 assert.equal(typeof globalThis.pantasStudyInsights,'function','shared server insight bridge exists');
 const out=JSON.parse(globalThis.pantasStudyInsights(JSON.stringify({examId:'exam_cse',now:'2026-10-24T10:00:00',sessions:[],attempts:[],mocks:[],lessons:[],reviews:[],topics:[]})));
 assert.equal(out.profile,null);
 for(const key of ['pressure','stamina','study','speed','memory']){
  assert.equal(out.tendencies[key].confidence,'early');
  assert.equal(out.tendencies[key].value,null);
 }
 assert.equal(out.whenYouWork,null);
});

const {readFileSync}=await import('node:fs');
const fixture=name=>JSON.parse(readFileSync(new URL('../../server_dart/fixtures/'+name,import.meta.url),'utf8'));
function close(a,b,path='root'){
 if(typeof a==='number'&&typeof b==='number'){assert.ok(Math.abs(a-b)<=1e-12*Math.max(1,Math.abs(a),Math.abs(b)),path);return;}
 if(a===null||b===null||typeof a!=='object'||typeof b!=='object'){assert.deepEqual(a,b,path);return;}
 assert.deepEqual(Object.keys(a),Object.keys(b),path);
 for(const key of Object.keys(a))close(a[key],b[key],path+'.'+key);
}
for(const[name,input]of Object.entries(fixture('insights_scenarios.json'))){
 test('populated '+name+' VM/JS insight output agrees, including confidence and profile',()=>{
  close(JSON.parse(globalThis.pantasStudyInsights(JSON.stringify(input))),fixture('insights_expected.json')[name]);
 });
}
