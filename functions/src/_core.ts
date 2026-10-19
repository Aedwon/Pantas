/**
 * The compiled Dart core: the roadmap engine and the mock paper sampler, built by
 * server_dart/build.sh into generated/pantas_core.js. Both functions are pure JSON in, JSON out.
 */
type CoreFunction = (json: string) => string;
type Core = {buildRoadmap: CoreFunction; sampleMock: CoreFunction};

let loaded: Core | undefined;

export function core(): Core {
  if (!loaded) {
    // The compiled file sets two globals when it is loaded; keep them out of the rest of the code.
    // eslint-disable-next-line @typescript-eslint/no-require-imports
    require('./generated/pantas_core.js');
    const scope = globalThis as unknown as {pantasBuildRoadmap: CoreFunction; pantasSampleMock: CoreFunction};
    loaded = {buildRoadmap: scope.pantasBuildRoadmap, sampleMock: scope.pantasSampleMock};
  }
  return loaded;
}
