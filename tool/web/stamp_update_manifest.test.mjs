import test from 'node:test';
import assert from 'node:assert/strict';
import {mkdtempSync,mkdirSync,writeFileSync,readFileSync,existsSync,rmSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
import vm from 'node:vm';
import {stamp} from './stamp_worker_version.mjs';
export function fixture() {
 const dir=mkdtempSync(join(tmpdir(),'pantas-build-'));mkdirSync(join(dir,'assets'));
 for(const [name,bytes] of Object.entries({'index.html':'<html><head><style>src:url(assets/assets/fonts/Geist-Regular.ttf)</style></head><script src="pantas_pwa.js"></script><script src="flutter_bootstrap.js"></script></html>',
 'flutter_bootstrap.js':'pwa.registerWorker("123");','pantas_sw.js':readFileSync('web/pantas_sw.js','utf8'),
 'version.json':'{}','main.dart.js':'main','main.dart.js_1.part.js':'old part','sqlite3.wasm':'wasm','drift_worker.js':'worker',
 'pantas_history.js':'history','pantas_splash.js':'splash','pantas_welcome.js':'welcome','pantas_pwa.js':'helper','assets/a':'asset'}))writeFileSync(join(dir,name),bytes);
 return dir;
}
test('stamp moves build files, publishes hashes and pins index plus root loader',()=>{
 const dir=fixture();try{
 const version=stamp(dir);const base='/b/'+version+'/';
 for(const name of ['main.dart.js','main.dart.js_1.part.js','assets/a','sqlite3.wasm','drift_worker.js','pantas_pwa.js','pantas_history.js','pantas_splash.js','pantas_welcome.js']) {
 assert.ok(existsSync(join(dir,base,name)),name);assert.ok(!existsSync(join(dir,name)),name+' root');}
 const index=readFileSync(join(dir,'index.html'),'utf8');assert.ok(index.includes('data-pantas-build="'+version+'"'));assert.ok(index.includes(base+'pantas_pwa.js'));assert.ok(index.includes('url('+base+'assets/assets/fonts/Geist-Regular.ttf)'));
 const inventory=JSON.parse(readFileSync(join(dir,base,'files.json')));assert.ok(inventory.files['main.dart.js_1.part.js']);
 let loaded;vm.runInNewContext(readFileSync(join(dir,'flutter_bootstrap.js'),'utf8'), {document:{documentElement:{dataset:{pantasBuild:version}},createElement:()=>({}),head:{appendChild:s=>loaded=s.src}}});
 assert.equal(loaded,base+'flutter_bootstrap.js');assert.equal(stamp(dir),version);
 }finally{rmSync(dir,{recursive:true,force:true});}
});
test('accepts the exact Flutter 3.44.6 deprecated version token expansion',()=>{
 const d=fixture();try{writeFileSync(join(d,'flutter_bootstrap.js'),'var version = "123" /* Flutter deprecation comment */;');
 assert.match(stamp(d),/^123-[0-9a-f]{12}$/);
 }finally{rmSync(d,{recursive:true,force:true});}
});
test('fresh Flutter output cannot inherit stale packaged folders into its hash or deployment',()=>{
 const fresh=fixture(),stale=fixture();try{
 mkdirSync(join(stale,'b','unverified-old'),{recursive:true});writeFileSync(join(stale,'b','unverified-old','main.dart.js'),'old');
 const expected=stamp(fresh);assert.equal(stamp(stale),expected);assert.ok(!existsSync(join(stale,'b','unverified-old')));
 }finally{rmSync(fresh,{recursive:true,force:true});rmSync(stale,{recursive:true,force:true});}
});
test('root loader upgrades a cached legacy flat index that has no pinned version',()=>{
 const dir=fixture();try{const version=stamp(dir);let loaded;
 vm.runInNewContext(readFileSync(join(dir,'flutter_bootstrap.js'),'utf8'),{document:{documentElement:{dataset:{}},createElement:()=>({}),head:{appendChild:s=>loaded=s.src}}});
 assert.equal(loaded,'/b/'+version+'/flutter_bootstrap.js');
 }finally{rmSync(dir,{recursive:true,force:true});}
});
