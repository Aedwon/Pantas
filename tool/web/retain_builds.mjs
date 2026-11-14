// Preparation only. Never invokes a hosting service or deploys anything.
import {createHash} from 'node:crypto';
import {mkdirSync,writeFileSync,readFileSync,readdirSync,rmSync,existsSync} from 'node:fs';
import {join} from 'node:path';
import {digest} from './stamp_worker_version.mjs';
function safePath(path) {
  if(typeof path!=='string' || !path || path.split('/').some(p=>!p || p==='.' || p==='..') || /[\\?#:%\x00-\x20]/.test(path)) throw Error('Invalid inventory path: '+path);
  return path;
}
function safeVersion(v) {if(typeof v!=='string'||!/^[A-Za-z0-9_-]+$/.test(v))throw Error('Invalid build version');return v;}
export async function retainBuilds(dir, origin, fetcher=fetch) {
  const current=JSON.parse(readFileSync(join(dir,'version.json')));
  const version=safeVersion(current.pantasBuildVersion);
  const base=new URL(origin);if(!['https:','http:'].includes(base.protocol))throw Error('Invalid origin');
  async function get(path) {
    const response=await fetcher(new URL('/'+path,base).href,{cache:'no-store',signal:AbortSignal.timeout(30000)});
    if(!response.ok)throw Error('Cannot retain '+path+': '+response.status);
    return Buffer.from(await response.arrayBuffer());
  }
  const live=JSON.parse((await get('version.json')).toString());
  const keep=[version];
  const legacyFiles={};
  const folderLayout=Array.isArray(live.retainedVersions) && live.retainedVersions.includes(live.pantasBuildVersion);
  if(folderLayout) {
    const previous=[live.pantasBuildVersion,...(live.retainedVersions??[])];
    for(const v of [...new Set(previous)].filter(v=>v!==version).slice(0,2)) {
      safeVersion(v);const raw=await get('b/'+v+'/files.json');const inventory=JSON.parse(raw);
      if(inventory.version!==v || !inventory.files || !Object.keys(inventory.files).length)throw Error('Invalid build inventory');
      const target=join(dir,'b',v);
      for(const [name,hash] of Object.entries(inventory.files)) {
        safePath(name);const bytes=await get('b/'+v+'/'+name);
        if(digest(bytes)!==hash)throw Error('Build hash mismatch: '+name);
        mkdirSync(join(target,name,'..'),{recursive:true});writeFileSync(join(target,name),bytes);
      }
      writeFileSync(join(target,'files.json'),raw);keep.push(v);
    }
  } else {
    // FIRST ROLLOUT ONLY: Flutter's generated flat worker publishes MD5 hashes
    // for all resources, including deferred parts. Never infer a partial list.
    const worker=(await get('flutter_service_worker.js')).toString();
    const match=worker.match(/(?:const|var) RESOURCES\s*=\s*(\{[\s\S]*?\});/);
    if(!match)throw Error('Legacy flat build has no published RESOURCES inventory');
    const resources=JSON.parse(match[1]);
    if(!resources['main.dart.js'])throw Error('Incomplete legacy inventory');
    for(const [name,hash] of Object.entries(resources)) {
      if(['/', 'index.html','flutter_bootstrap.js','version.json','manifest.json','pantas_sw.js','flutter_service_worker.js','favicon.png','og-image.png'].includes(name)||name.startsWith('icons/'))continue;
      safePath(name);if(existsSync(join(dir,name)))throw Error('Legacy root collision: '+name);
      const bytes=await get(name);
      if(createHash('md5').update(bytes).digest('hex')!==hash)throw Error('Legacy hash mismatch: '+name);
      mkdirSync(join(dir,name,'..'),{recursive:true});writeFileSync(join(dir,name),bytes);legacyFiles[name]=digest(bytes);
    }
    current.legacyFlat=true;
  }
  for(const name of readdirSync(join(dir,'b')))if(!keep.includes(name))rmSync(join(dir,'b',name),{recursive:true,force:true});
  if(folderLayout)delete current.legacyFlat;
  writeFileSync(join(dir,'version.json'),JSON.stringify({...current,retainedVersions:keep}));
  const workerPath=join(dir,'pantas_sw.js');
  writeFileSync(workerPath,readFileSync(workerPath,'utf8').replace(/const RETAINED_VERSIONS = .*?;/,'const RETAINED_VERSIONS = '+JSON.stringify(keep)+';')
    .replace(/const LEGACY_FILES = .*?;/,'const LEGACY_FILES = '+JSON.stringify(legacyFiles)+';'));
  return keep;
}
if(import.meta.url===`file://${process.argv[1]}`) {
  if(!process.argv[2])throw Error('Usage: node tool/web/retain_builds.mjs LIVE_ORIGIN [build/web]');
  console.log('Retained builds: '+(await retainBuilds(process.argv[3]??'build/web',process.argv[2])).join(', '));
}
