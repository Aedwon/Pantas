/**
 * The compiled Dart core: roadmap, mock sampling and review scheduling, built by
 * server_dart/build.sh into generated/pantas_core.js. Its functions are pure JSON in, JSON out.
 */
type CoreFunction = (json: string) => string;
type Core = {sessionDiagnosis: CoreFunction; roadmapState: CoreFunction; studyInsights: CoreFunction; buildRoadmap: CoreFunction; sampleMock: CoreFunction; scheduleReviews: CoreFunction; dueReviews: CoreFunction};

let loaded: Core | undefined;

export function core(): Core {
  if (!loaded) {
    // The compiled file sets the exported globals when loaded; keep them out of the rest of the code.
    // eslint-disable-next-line @typescript-eslint/no-require-imports
    require('./generated/pantas_core.js');
    const scope = globalThis as unknown as {pantasSessionDiagnosis: CoreFunction; pantasRoadmapState: CoreFunction; pantasStudyInsights: CoreFunction; pantasBuildRoadmap: CoreFunction; pantasSampleMock: CoreFunction; pantasScheduleReviews: CoreFunction; pantasDueReviews: CoreFunction};
    loaded = {sessionDiagnosis: scope.pantasSessionDiagnosis, roadmapState: scope.pantasRoadmapState, studyInsights: scope.pantasStudyInsights, buildRoadmap: scope.pantasBuildRoadmap, sampleMock: scope.pantasSampleMock, scheduleReviews: scope.pantasScheduleReviews, dueReviews: scope.pantasDueReviews};
  }
  return loaded;
}
