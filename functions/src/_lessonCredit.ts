/** Pure family credit. Direct credit wins; split times use the earliest parent,
 * merge times use the last required parent. Callers count only active ids. */
export function lessonCredit<T>(retired: Record<string,string[]>, own: Map<string,T>, compare:(a:T,b:T)=>number):Map<string,T> {
 const split=new Map<string,string[]>(), merge=new Map<string,string[]>();
 for(const [parent,replacements] of Object.entries(retired)) {
  const targets=new Set(replacements), incoming=targets.size>=2?split:merge;
  for(const id of targets)incoming.set(id,[...(incoming.get(id)??[]),parent]);
 }
 const resolve=(id:string,visited:Set<string>):T|undefined=>{
  if(own.has(id))return own.get(id);
  if(visited.has(id))return undefined;
  visited.add(id);
  let result:T|undefined;
  for(const parent of split.get(id)??[]) {
   const value=resolve(parent,new Set(visited));
   if(value!==undefined&&(result===undefined||compare(value,result)<0))result=value;
  }
  const parents=merge.get(id)??[];
  let merged:T|undefined, all=parents.length>0;
  for(const parent of parents) {
   const value=resolve(parent,new Set(visited));
   if(value===undefined){all=false;break;}
   if(merged===undefined||compare(value,merged)>0)merged=value;
  }
  if(all&&merged!==undefined&&(result===undefined||compare(merged,result)<0))result=merged;
  return result;
 };
 const result=new Map<string,T>();
 for(const id of new Set([...own.keys(),...split.keys(),...merge.keys()])) {
  const value=resolve(id,new Set());
  if(value!==undefined)result.set(id,value);
 }
 return result;
}
