import test from 'node:test';
import assert from 'node:assert/strict';
import {mkdtempSync,mkdirSync,writeFileSync,readFileSync,existsSync,rmSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
import {createHash} from 'node:crypto';
import {retainBuilds} from './retain_builds.mjs';
const hash=(s,kind='sha256')=>createHash(kind).update(s).digest('hex');
function local() {const d=mkdtempSync(join(tmpdir(),'pantas-retain-'));mkdirSync(join(d,'b/new'),{recursive:true});writeFileSync(join(d,'version.json'),JSON.stringify({pantasBuildVersion:'new',retainedVersions:['new']}));writeFileSync(join(d,'pantas_sw.js'),'const RETAINED_VERSIONS = [];');return d;}
function server(files) {return async url=>{const name=new URL(typeof url==='string'?url:url.url).pathname.slice(1);return name in files ? new Response(typeof files[name]==='string'?files[name]:JSON.stringify(files[name])) : new Response('missing',{status:404});};}
test('retains live current and predecessor beside new build, drops older folder',async()=>{
 const d=local();try{mkdirSync(join(d,'b/expired'));
 const files={'version.json':{pantasBuildVersion:'live',retainedVersions:['live','previous','expired']}};
 for(const v of ['live','previous']) {files[`b/${v}/files.json`]={version:v,files:{'x.part.js':hash(v)}};files[`b/${v}/x.part.js`]=v;}
 assert.deepEqual(await retainBuilds(d,'https://app.example',server(files)),['new','live','previous']);
 assert.equal(readFileSync(join(d,'b/live/x.part.js'),'utf8'),'live');assert.ok(!existsSync(join(d,'b/expired')));
 assert.deepEqual(JSON.parse(readFileSync(join(d,'version.json'))).retainedVersions,['new','live','previous']);
 assert.match(readFileSync(join(d,'pantas_sw.js'),'utf8'),/new.*live.*previous/);
 }finally{rmSync(d,{recursive:true,force:true});}
});
test('explicit legacy flat step retains missing deferred parts and assets once, next deployment drops them',async()=>{
 const d=local();try{
 const resources={'main.dart.js':hash('legacy main','md5'),'main.dart.js_7.part.js':hash('legacy part','md5'),'assets/a':hash('legacy asset','md5'),'index.html':hash('old index','md5')};
 const files={'version.json':{version:'1.0',pantasBuildVersion:'flat-stamped'},'flutter_service_worker.js':'const RESOURCES = '+JSON.stringify(resources)+';',
 'main.dart.js':'legacy main','main.dart.js_7.part.js':'legacy part','assets/a':'legacy asset'};
 await retainBuilds(d,'https://app.example',server(files));
 assert.equal(readFileSync(join(d,'main.dart.js_7.part.js'),'utf8'),'legacy part');assert.equal(readFileSync(join(d,'assets/a'),'utf8'),'legacy asset');
 assert.equal(JSON.parse(readFileSync(join(d,'version.json'))).legacyFlat,true);assert.ok(!existsSync(join(d,'index.html')));
 const next=local();try{await retainBuilds(next,'https://app.example',server({'version.json':{pantasBuildVersion:'live',retainedVersions:['live'],legacyFlat:true},'b/live/files.json':{version:'live',files:{'x':hash('live')}},'b/live/x':'live'}));
 assert.ok(!existsSync(join(next,'main.dart.js_7.part.js')));assert.equal(JSON.parse(readFileSync(join(next,'version.json'))).legacyFlat,undefined);
 }finally{rmSync(next,{recursive:true,force:true});}
 }finally{rmSync(d,{recursive:true,force:true});}
});
test('missing, HTML, tampered or traversal inventory fails closed',async()=>{
 for(const entry of [{name:'../escape',bytes:'x',digest:hash('x')},{name:'x.js',bytes:'wrong',digest:hash('right')}]) {
 const d=local();try{await assert.rejects(retainBuilds(d,'https://app.example',server({'version.json':{pantasBuildVersion:'live',retainedVersions:['live']},'b/live/files.json':{version:'live',files:{[entry.name]:entry.digest}},['b/live/'+entry.name]:entry.bytes})));}finally{rmSync(d,{recursive:true,force:true});}}
});
test('unavailable or HTML published inventory stops preparation',async()=>{
 for(const inventory of [undefined,'<!doctype html><html>SPA rewrite</html>']){
 const d=local();try{const remote={'version.json':{pantasBuildVersion:'live',retainedVersions:['live']}};
 if(inventory)remote['b/live/files.json']=inventory;
 await assert.rejects(retainBuilds(d,'https://app.example',server(remote)));
 assert.deepEqual(JSON.parse(readFileSync(join(d,'version.json'))).retainedVersions,['new']);
 }finally{rmSync(d,{recursive:true,force:true});}}
});
