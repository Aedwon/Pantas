// A small Firestore stand-in for unit tests: doc get/set/delete, collection get, serialized transactions.
export function fakeFirestore(initial = {}) {
  const rows = new Map(Object.entries(initial));
  let chain = Promise.resolve();
  const snap = (path) => ({
    id: path.split('/').at(-1), exists: rows.has(path), data: () => rows.get(path),
    get: field => rows.get(path)?.[field],
  });
  const write = (path, data, options) => rows.set(path, options?.merge ? {...rows.get(path), ...data} : {...data});
  const ref = path => ({
    path,
    get: async () => snap(path),
    set: async (data, options) => { write(path, data, options); },
    delete: async () => { rows.delete(path); },
  });
  return {
    rows,
    doc: ref,
    collection: base => ({
      get: async () => {
        const docs = [...rows.keys()].filter(p => p.startsWith(`${base}/`) && !p.slice(base.length + 1).includes('/'))
          .map(snap);
        return {docs, empty: docs.length === 0};
      },
    }),
    runTransaction: fn => {
      const run = chain.then(() => fn({
        get: async r => snap(r.path),
        set: (r, data, options) => { write(r.path, data, options); },
        delete: r => { rows.delete(r.path); },
      }));
      chain = run.catch(() => {});
      return run;
    },
  };
}
