# C7 client on web: lead ruling (October 19, 2026)

Technical plan revision by the Claude lead. It refines plan task C7 ("W4 screens keep reading
through the existing content repository; the repository fetches and caches"). No product or spec
change: no student-visible behavior changes beyond C7 as approved.

## Finding

Commit 84651f59 on `web/pwa-staging-r1` adds `ContentService` and an encrypted cache, but nothing
reads them. On web, `contentDatabaseProvider` is never overridden. About 15 callers read it
directly (repositories, `storage.dart`, `track_scope.dart`, home and progress providers,
`sync_runtime_bootstrap.dart`) and some run their own queries over the content tables. The
server serves lessons and question sets only by id; it has no list of exams, subjects, topics,
lessons or questions. So web cannot show a study map or run a query by topic.

## Ruling

1. **Keep every caller unchanged.** On web, open a `ContentDatabase` in memory (drift on
   sqlite3 wasm, in-memory) and override `contentDatabaseProvider` with it. Native builds are
   unchanged. Every existing query keeps working because the same tables exist.
2. **A catalog per exam from the server.** Add kind `catalog` to `getContent` (same auth, App
   Check, daily limit, versioning and tier suffix). Id `index` returns the exam, subject and topic
   rows. Id `<examId>` returns that exam's structure: subjects, topics, lesson rows without
   `body`, question index rows (id, topic, subtopic, exam links, active flag, and the other
   non-text columns the content tables require) without stem, choices or explanation,
   diagnostic set and mock blueprint rows. The uploader writes these documents. Each must stay
   under the Firestore 1 MiB document limit; split by subject if needed. Titles and ids are not
   protected content.
3. **Fill the in-memory database from the encrypted cache.** At start, the web bootstrap loads the
   cached catalog and cached items (the `CachedContent` table in the encrypted study database)
   into the in-memory database, then refreshes in the background. Each `ContentService.changes`
   event upserts its rows, so a downgrade to Free also strips notes from the in-memory rows.
4. **Fetch before reading text.** Lesson body and question text are filled when fetched. On web,
   `LessonRepo.findById` and the question queries that hydrate text (`byTopic`, `bySubtopic`,
   `byExam`, `findById`, `byIds`) first make sure the needed lesson or question sets are fetched,
   through a web-only hook passed to the repository. Public repository signatures do not change.
   Preload the next lessons on the student's roadmap with `preloadAfter`.
5. **Mock papers stay with C8b.** The web client does not assemble mock papers from the in-memory
   database.
6. **Order of work.** The client side runs now against a fake `ContentRemote`. The server side
   (catalog in `getContent` and the uploader) waits until `web/roadmap-server-r1` merges into
   `web/pwa-staging-r1`, because that branch also changes `contentUpload.ts` and
   `tools/upload_content`.

## Accepted limits

- A student offline before any catalog has arrived sees no content. The first open needs a
  connection. This already follows from C7.
- The in-memory database is rebuilt at each start from the encrypted cache: some cost at start-up,
  measured in B8.
