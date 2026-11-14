// Run after a fresh flutter build web, before retain_builds.mjs.
import {createHash} from 'node:crypto';
import {existsSync, readdirSync, readFileSync, statSync, writeFileSync, mkdirSync, renameSync, rmSync} from 'node:fs';
import {join, relative} from 'node:path';
const TOKEN = /registerWorker\("([^"]*)"/;
const ROOT = new Set(['index.html','flutter_bootstrap.js','version.json','manifest.json','pantas_sw.js','favicon.png','og-image.png']);
export function files(dir, root = dir) {
  return readdirSync(dir).filter(n => !n.startsWith('.')).sort().flatMap(n => {
    const path = join(dir,n);return statSync(path).isDirectory() ? files(path,root) : [relative(root,path)];
  });
}
export const digest = bytes => createHash('sha256').update(bytes).digest('hex');
export function buildHash(dir) {
  const hash = createHash('sha256');
  for (const name of files(dir)) hash.update(name).update('\0').update(readFileSync(join(dir,name))).update('\0');
  return hash.digest('hex').slice(0,12);
}
function writeRootLoader(dir,version) {
  writeFileSync(join(dir,'flutter_bootstrap.js'),`(function(){var v=document.documentElement.dataset.pantasBuild||${JSON.stringify(version)};if(!/^[A-Za-z0-9_-]+$/.test(v))throw Error('Missing build version');var s=document.createElement('script');s.src='/b/'+v+'/flutter_bootstrap.js';document.head.appendChild(s);})();\n`);
}
export function stamp(dir) {
  const metadataPath=join(dir,'version.json');
  const metadata=existsSync(metadataPath)?JSON.parse(readFileSync(metadataPath)):{};
  if (metadata.pantasBuildVersion && existsSync(join(dir,'b',metadata.pantasBuildVersion,'files.json'))) {
    writeRootLoader(dir,metadata.pantasBuildVersion);
    return metadata.pantasBuildVersion;
  }
  const bootstrap=readFileSync(join(dir,'flutter_bootstrap.js'),'utf8');
  // Flutter expands this token to a quoted version before packaging.
  const match=bootstrap.match(/var version = "([^"]*)"/) || bootstrap.match(TOKEN);
  if(!match) throw Error('No registerWorker or Flutter version token in bootstrap');
  // Flutter overwrites its flat output but leaves our prior b/ directory.
  // Retention must recover only verified live folders, never this stale output.
  rmSync(join(dir,'b'),{recursive:true,force:true});
  const version=match[1].split('-')[0]+'-'+buildHash(dir);
  const base='/b/'+version+'/';const target=join(dir,'b',version);mkdirSync(target,{recursive:true});
  // Pin generated bootstrap as well as all pre-Flutter helper scripts.
  writeFileSync(join(target,'flutter_bootstrap.js'),bootstrap.replace(match[0],match[0].replace(match[1],version)));
  for(const name of readdirSync(dir)) {
    if(name.startsWith('.') || name==='b' || name==='icons' || ROOT.has(name)) continue;
    if(name==='flutter_service_worker.js') {rmSync(join(dir,name));continue;}
    renameSync(join(dir,name),join(target,name));
  }
  const indexPath=join(dir,'index.html');
  if(existsSync(indexPath)) {
    let index=readFileSync(indexPath,'utf8').replace('<html','<html data-pantas-build="'+version+'"');
    index=index.replace(/src="(pantas_[^"]+\.js)"/g, 'src="'+base+'$1"');
    index=index.replace(/(?<=[\"'(])assets\//g,base+'assets/');
    writeFileSync(indexPath,index);
  }
  // This loader works with any cached index, even across later deployments.
  writeRootLoader(dir,version);
  const inventory=Object.fromEntries(files(target).map(n=>[n,digest(readFileSync(join(target,n)))]));
  writeFileSync(join(target,'files.json'),JSON.stringify({version,files:inventory}));
  writeFileSync(metadataPath,JSON.stringify({...metadata,pantasBuildVersion:version,retainedVersions:[version]}));
  const worker=join(dir,'pantas_sw.js');
  if(existsSync(worker))writeFileSync(worker,readFileSync(worker,'utf8')
    .replace(/const STAMPED_VERSION = .*?;/,'const STAMPED_VERSION = '+JSON.stringify(version)+';')
    .replace(/const RETAINED_VERSIONS = .*?;/,'const RETAINED_VERSIONS = '+JSON.stringify([version])+';')
    .replace(/const BUILD_FILES = .*?;/,'const BUILD_FILES = '+JSON.stringify(Object.keys(inventory))+';')
    .replace(/const BUILD_HASHES = .*?;/,'const BUILD_HASHES = '+JSON.stringify(inventory)+';'));
  return version;
}
if(import.meta.url===`file://${process.argv[1]}`)console.log('Build version: '+stamp(process.argv[2]??'build/web'));
