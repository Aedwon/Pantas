# B3 encrypted web database, second pass

Date: October 19, 2026. Policy: origin/main 6801eb10b5938c4e615e176e5fe2507ea76a68bb.
Source: web/pwa-foundation-r1, HEAD 5e6cda4541a80609b27f2784fc2e58d39731a33b plus the existing and continued uncommitted B2/B3 patch.
The lead supplied the remote identities. No fetch, commit, push, branch change, package regeneration, or production-key read occurred. During the run another process advanced origin/main to 7cc0a80c6c1d667ef9e5ca0658cd67ba1674b2eb. The policy files did not change. The later Firebase record explicitly leaves config insertion to the lead after this pass; this run preserves the requested placeholders.

## Result

The supported sqlite3 3.5.1 wasm works with the upstream `multipleciphers-<vfs>` shim. Direct Dart VFS opens fail. URI opens require `uri: true`; setting the URI text without that flag does not activate the shim. Neither registration before/after a first open nor makeDefault true/false changes these results.

The shipped wasm remains unchanged, SHA-256 `62a34ec725631c0438e4255ce0c6059099bf8e7fb331e7d4d91a38e075f43a19`. It enables ChaCha20 only. No custom engine was built.

## Upstream search and maintainer statements

GitHub REST issue search, including closed issues and pull requests, returned:
- `repo:simolus3/sqlite3.dart "Encryption is not supported"`: 0 results.
- `repo:simolus3/sqlite3.dart encryption VFS`: 4 results.
  - [Cross platform DB encryption](https://github.com/simolus3/sqlite3.dart/issues/85)
  - [I have written a couple packages for SQLite3MultipleCiphers that work cross platform.](https://github.com/simolus3/sqlite3.dart/issues/136)
  - [Initial support for encryption on the web](https://github.com/simolus3/sqlite3.dart/pull/274)
  - [Web support](https://github.com/simolus3/sqlite3.dart/pull/80)
- `repo:simolus3/sqlite3.dart multipleciphers`: 0 results.
- `repo:simolus3/sqlite3.dart encryption IndexedDbFileSystem`: 0 results.
- `repo:simolus3/sqlite3.dart encryption OPFS`: 0 results.

Repository metadata says `has_discussions: false`. A web search for `site:github.com/simolus3/sqlite3.dart/discussions encryption` found no repository discussion. No maintainer response to the exact error was found.

Maintainer simolus3 says in [issue 136](https://github.com/simolus3/sqlite3.dart/issues/136#issuecomment-3477840043):

> These are drop-in replacements that should also work with drift if you set the encryption pragma in your migration logic.

The [initial web encryption PR 274](https://github.com/simolus3/sqlite3.dart/pull/274) explains the initialization order problem:

> that extension sets up an extrainit to turn the default vfs into an encrypted vfs.

The locked [changelog, version 2.6.0](https://github.com/simolus3/sqlite3.dart/blob/sqlite3-3.5.1/sqlite3/CHANGELOG.md) introduced experimental web encryption. The current README example registers an ordinary Dart VFS and opens it directly. That specific example fails in this locked release.

The [SQLite3MultipleCiphers VFS FAQ](https://utelle.github.io/SQLite3MultipleCiphers/docs/faq/faq_overview/) gives the missing operation:

> simply prefixing the VFS name with the string `multipleciphers-`.

The [URI documentation](https://utelle.github.io/SQLite3MultipleCiphers/docs/configuration/config_uri/) and [SQLite URI reference](https://www.sqlite.org/uri.html) describe `vfs=NAME`. Tests used the shim URI but kept the key in PRAGMA, avoiding credentials in the URI.

The [v2.5.0 VFS source](https://github.com/utelle/SQLite3MultipleCiphers/blob/v2.5.0/src/sqlite3mc_vfs.c) calls `sqlite3mc_vfs_create(zVfsReal, 0)` when resolving the shim name. The function wraps the registered underlying VFS. It does not have to be exported to Dart. The wasm exports only `dart_sqlite3_register_vfs` and `dart_sqlite3_unregister_vfs` for VFS registration. Their absence in the prior export search did not establish an encryption blocker.

## Reproduction and limits

The plain Node run has no native IndexedDB or OPFS. The adapter run executes the actual Dart IndexedDbFileSystem and SimpleOpfsFileSystem classes over fake-indexeddb 6.2.4 and a small synthetic OPFS host. The wasm and Dart VFS implementations are real. The browser storage APIs in this host are adapters, not browser acceptance evidence. Registration order and default selection are crossed for every VFS. Each successful shim case writes, rejects a wrong key, and reopens with the correct key.

Commands:

```sh
npm install --prefix /tmp/pantas-pwa-probe --cache /tmp/pantas-npm-cache --no-audit --no-fund fake-indexeddb@6.2.4
dart compile js tool/web/probe_encrypted_wasm.dart -o build/probe_encrypted_wasm.js
node tool/web/probe_encrypted_wasm.cjs
node tool/web/probe_browser_host.cjs
dart compile js tool/web/verify_web_database.dart -o build/verify_web_database.js
PANTAS_PROBE_SCRIPT=verify_web_database.js node tool/web/probe_browser_host.cjs
```

The host requires an explicit completion callback. A Node process exiting without running Dart main cannot pass.

### Attempt 1: plain Node, exact output

```text
memory afterOpen=false default=false plain: SqliteException(1): while executing, Setting key failed. Encryption is not supported by the VFS., SQL logic error (code 1)
  Causing statement: PRAGMA key = "x'abababababababababababababababababababababababababababababababab'";, parameters: 
memory afterOpen=false default=false uri-direct: SqliteException(1): while executing, Setting key failed. Encryption is not supported by the VFS., SQL logic error (code 1)
  Causing statement: PRAGMA key = "x'abababababababababababababababababababababababababababababababab'";, parameters: 
memory afterOpen=false default=false uri-shim: cipher=[{chacha20: chacha20}] key + write accepted [{value: synthetic}]
memory afterOpen=false default=false uri-shim: wrong key rejected: SqliteException(26): while preparing statement, file is not a database, file is not a database (code 26)
  Causing statement: SELECT * FROM probe
memory afterOpen=false default=false uri-shim: correct key reopen [{n: 1}]
memory afterOpen=false default=false uri-default-flag: SqliteException(1): while executing, Setting key failed. Encryption is not supported by the VFS., SQL logic error (code 1)
  Causing statement: PRAGMA key = "x'abababababababababababababababababababababababababababababababab'";, parameters: 
memory afterOpen=false default=false argument-shim: cipher=[{chacha20: chacha20}] key + write accepted [{value: synthetic}]
memory afterOpen=false default=false argument-shim: wrong key rejected: SqliteException(26): while preparing statement, file is not a database, file is not a database (code 26)
  Causing statement: SELECT * FROM probe
memory afterOpen=false default=false argument-shim: correct key reopen [{n: 1}]
memory afterOpen=false default=true plain: SqliteException(1): while executing, Setting key failed. Encryption is not supported by the VFS., SQL logic error (code 1)
  Causing statement: PRAGMA key = "x'abababababababababababababababababababababababababababababababab'";, parameters: 
memory afterOpen=false default=true uri-direct: SqliteException(1): while executing, Setting key failed. Encryption is not supported by the VFS., SQL logic error (code 1)
  Causing statement: PRAGMA key = "x'abababababababababababababababababababababababababababababababab'";, parameters: 
memory afterOpen=false default=true uri-shim: cipher=[{chacha20: chacha20}] key + write accepted [{value: synthetic}]
memory afterOpen=false default=true uri-shim: wrong key rejected: SqliteException(26): while preparing statement, file is not a database, file is not a database (code 26)
  Causing statement: SELECT * FROM probe
memory afterOpen=false default=true uri-shim: correct key reopen [{n: 1}]
memory afterOpen=false default=true uri-default-flag: SqliteException(1): while executing, Setting key failed. Encryption is not supported by the VFS., SQL logic error (code 1)
  Causing statement: PRAGMA key = "x'abababababababababababababababababababababababababababababababab'";, parameters: 
memory afterOpen=false default=true argument-shim: cipher=[{chacha20: chacha20}] key + write accepted [{value: synthetic}]
memory afterOpen=false default=true argument-shim: wrong key rejected: SqliteException(26): while preparing statement, file is not a database, file is not a database (code 26)
  Causing statement: SELECT * FROM probe
memory afterOpen=false default=true argument-shim: correct key reopen [{n: 1}]
memory afterOpen=true default=false plain: SqliteException(1): while executing, Setting key failed. Encryption is not supported by the VFS., SQL logic error (code 1)
  Causing statement: PRAGMA key = "x'abababababababababababababababababababababababababababababababab'";, parameters: 
memory afterOpen=true default=false uri-direct: SqliteException(1): while executing, Setting key failed. Encryption is not supported by the VFS., SQL logic error (code 1)
  Causing statement: PRAGMA key = "x'abababababababababababababababababababababababababababababababab'";, parameters: 
memory afterOpen=true default=false uri-shim: cipher=[{chacha20: chacha20}] key + write accepted [{value: synthetic}]
memory afterOpen=true default=false uri-shim: wrong key rejected: SqliteException(26): while preparing statement, file is not a database, file is not a database (code 26)
  Causing statement: SELECT * FROM probe
memory afterOpen=true default=false uri-shim: correct key reopen [{n: 1}]
memory afterOpen=true default=false uri-default-flag: SqliteException(1): while executing, Setting key failed. Encryption is not supported by the VFS., SQL logic error (code 1)
  Causing statement: PRAGMA key = "x'abababababababababababababababababababababababababababababababab'";, parameters: 
memory afterOpen=true default=false argument-shim: cipher=[{chacha20: chacha20}] key + write accepted [{value: synthetic}]
memory afterOpen=true default=false argument-shim: wrong key rejected: SqliteException(26): while preparing statement, file is not a database, file is not a database (code 26)
  Causing statement: SELECT * FROM probe
memory afterOpen=true default=false argument-shim: correct key reopen [{n: 1}]
memory afterOpen=true default=true plain: SqliteException(1): while executing, Setting key failed. Encryption is not supported by the VFS., SQL logic error (code 1)
  Causing statement: PRAGMA key = "x'abababababababababababababababababababababababababababababababab'";, parameters: 
memory afterOpen=true default=true uri-direct: SqliteException(1): while executing, Setting key failed. Encryption is not supported by the VFS., SQL logic error (code 1)
  Causing statement: PRAGMA key = "x'abababababababababababababababababababababababababababababababab'";, parameters: 
memory afterOpen=true default=true uri-shim: cipher=[{chacha20: chacha20}] key + write accepted [{value: synthetic}]
memory afterOpen=true default=true uri-shim: wrong key rejected: SqliteException(26): while preparing statement, file is not a database, file is not a database (code 26)
  Causing statement: SELECT * FROM probe
memory afterOpen=true default=true uri-shim: correct key reopen [{n: 1}]
memory afterOpen=true default=true uri-default-flag: SqliteException(1): while executing, Setting key failed. Encryption is not supported by the VFS., SQL logic error (code 1)
  Causing statement: PRAGMA key = "x'abababababababababababababababababababababababababababababababab'";, parameters: 
memory afterOpen=true default=true argument-shim: cipher=[{chacha20: chacha20}] key + write accepted [{value: synthetic}]
memory afterOpen=true default=true argument-shim: wrong key rejected: SqliteException(26): while preparing statement, file is not a database, file is not a database (code 26)
  Causing statement: SELECT * FROM probe
memory afterOpen=true default=true argument-shim: correct key reopen [{n: 1}]
indexeddb afterOpen=false default=false: VFS setup failed: Null check operator used on a null value
indexeddb afterOpen=false default=true: VFS setup failed: Null check operator used on a null value
indexeddb afterOpen=true default=false: VFS setup failed: Null check operator used on a null value
indexeddb afterOpen=true default=true: VFS setup failed: Null check operator used on a null value
opfs afterOpen=false default=false: VFS setup failed: VfsException(1)
opfs afterOpen=false default=true: VFS setup failed: VfsException(1)
opfs afterOpen=true default=false: VFS setup failed: VfsException(1)
opfs afterOpen=true default=true: VFS setup failed: VfsException(1)
```

### Attempt 2: storage adapters, exact output

```text
memory afterOpen=false default=false plain: SqliteException(1): while executing, Setting key failed. Encryption is not supported by the VFS., SQL logic error (code 1)
  Causing statement: PRAGMA key = "x'abababababababababababababababababababababababababababababababab'";, parameters: 
memory afterOpen=false default=false uri-direct: SqliteException(1): while executing, Setting key failed. Encryption is not supported by the VFS., SQL logic error (code 1)
  Causing statement: PRAGMA key = "x'abababababababababababababababababababababababababababababababab'";, parameters: 
memory afterOpen=false default=false uri-shim: cipher=[{chacha20: chacha20}] key + write accepted [{value: synthetic}]
memory afterOpen=false default=false uri-shim: wrong key rejected: SqliteException(26): while preparing statement, file is not a database, file is not a database (code 26)
  Causing statement: SELECT * FROM probe
memory afterOpen=false default=false uri-shim: correct key reopen [{n: 1}]
memory afterOpen=false default=false uri-default-flag: SqliteException(1): while executing, Setting key failed. Encryption is not supported by the VFS., SQL logic error (code 1)
  Causing statement: PRAGMA key = "x'abababababababababababababababababababababababababababababababab'";, parameters: 
memory afterOpen=false default=false argument-shim: cipher=[{chacha20: chacha20}] key + write accepted [{value: synthetic}]
memory afterOpen=false default=false argument-shim: wrong key rejected: SqliteException(26): while preparing statement, file is not a database, file is not a database (code 26)
  Causing statement: SELECT * FROM probe
memory afterOpen=false default=false argument-shim: correct key reopen [{n: 1}]
memory afterOpen=false default=true plain: SqliteException(1): while executing, Setting key failed. Encryption is not supported by the VFS., SQL logic error (code 1)
  Causing statement: PRAGMA key = "x'abababababababababababababababababababababababababababababababab'";, parameters: 
memory afterOpen=false default=true uri-direct: SqliteException(1): while executing, Setting key failed. Encryption is not supported by the VFS., SQL logic error (code 1)
  Causing statement: PRAGMA key = "x'abababababababababababababababababababababababababababababababab'";, parameters: 
memory afterOpen=false default=true uri-shim: cipher=[{chacha20: chacha20}] key + write accepted [{value: synthetic}]
memory afterOpen=false default=true uri-shim: wrong key rejected: SqliteException(26): while preparing statement, file is not a database, file is not a database (code 26)
  Causing statement: SELECT * FROM probe
memory afterOpen=false default=true uri-shim: correct key reopen [{n: 1}]
memory afterOpen=false default=true uri-default-flag: SqliteException(1): while executing, Setting key failed. Encryption is not supported by the VFS., SQL logic error (code 1)
  Causing statement: PRAGMA key = "x'abababababababababababababababababababababababababababababababab'";, parameters: 
memory afterOpen=false default=true argument-shim: cipher=[{chacha20: chacha20}] key + write accepted [{value: synthetic}]
memory afterOpen=false default=true argument-shim: wrong key rejected: SqliteException(26): while preparing statement, file is not a database, file is not a database (code 26)
  Causing statement: SELECT * FROM probe
memory afterOpen=false default=true argument-shim: correct key reopen [{n: 1}]
memory afterOpen=true default=false plain: SqliteException(1): while executing, Setting key failed. Encryption is not supported by the VFS., SQL logic error (code 1)
  Causing statement: PRAGMA key = "x'abababababababababababababababababababababababababababababababab'";, parameters: 
memory afterOpen=true default=false uri-direct: SqliteException(1): while executing, Setting key failed. Encryption is not supported by the VFS., SQL logic error (code 1)
  Causing statement: PRAGMA key = "x'abababababababababababababababababababababababababababababababab'";, parameters: 
memory afterOpen=true default=false uri-shim: cipher=[{chacha20: chacha20}] key + write accepted [{value: synthetic}]
memory afterOpen=true default=false uri-shim: wrong key rejected: SqliteException(26): while preparing statement, file is not a database, file is not a database (code 26)
  Causing statement: SELECT * FROM probe
memory afterOpen=true default=false uri-shim: correct key reopen [{n: 1}]
memory afterOpen=true default=false uri-default-flag: SqliteException(1): while executing, Setting key failed. Encryption is not supported by the VFS., SQL logic error (code 1)
  Causing statement: PRAGMA key = "x'abababababababababababababababababababababababababababababababab'";, parameters: 
memory afterOpen=true default=false argument-shim: cipher=[{chacha20: chacha20}] key + write accepted [{value: synthetic}]
memory afterOpen=true default=false argument-shim: wrong key rejected: SqliteException(26): while preparing statement, file is not a database, file is not a database (code 26)
  Causing statement: SELECT * FROM probe
memory afterOpen=true default=false argument-shim: correct key reopen [{n: 1}]
memory afterOpen=true default=true plain: SqliteException(1): while executing, Setting key failed. Encryption is not supported by the VFS., SQL logic error (code 1)
  Causing statement: PRAGMA key = "x'abababababababababababababababababababababababababababababababab'";, parameters: 
memory afterOpen=true default=true uri-direct: SqliteException(1): while executing, Setting key failed. Encryption is not supported by the VFS., SQL logic error (code 1)
  Causing statement: PRAGMA key = "x'abababababababababababababababababababababababababababababababab'";, parameters: 
memory afterOpen=true default=true uri-shim: cipher=[{chacha20: chacha20}] key + write accepted [{value: synthetic}]
memory afterOpen=true default=true uri-shim: wrong key rejected: SqliteException(26): while preparing statement, file is not a database, file is not a database (code 26)
  Causing statement: SELECT * FROM probe
memory afterOpen=true default=true uri-shim: correct key reopen [{n: 1}]
memory afterOpen=true default=true uri-default-flag: SqliteException(1): while executing, Setting key failed. Encryption is not supported by the VFS., SQL logic error (code 1)
  Causing statement: PRAGMA key = "x'abababababababababababababababababababababababababababababababab'";, parameters: 
memory afterOpen=true default=true argument-shim: cipher=[{chacha20: chacha20}] key + write accepted [{value: synthetic}]
memory afterOpen=true default=true argument-shim: wrong key rejected: SqliteException(26): while preparing statement, file is not a database, file is not a database (code 26)
  Causing statement: SELECT * FROM probe
memory afterOpen=true default=true argument-shim: correct key reopen [{n: 1}]
indexeddb afterOpen=false default=false plain: SqliteException(1): while executing, Setting key failed. Encryption is not supported by the VFS., SQL logic error (code 1)
  Causing statement: PRAGMA key = "x'abababababababababababababababababababababababababababababababab'";, parameters: 
indexeddb afterOpen=false default=false uri-direct: SqliteException(1): while executing, Setting key failed. Encryption is not supported by the VFS., SQL logic error (code 1)
  Causing statement: PRAGMA key = "x'abababababababababababababababababababababababababababababababab'";, parameters: 
indexeddb afterOpen=false default=false uri-shim: cipher=[{chacha20: chacha20}] key + write accepted [{value: synthetic}]
indexeddb afterOpen=false default=false uri-shim: wrong key rejected: SqliteException(26): while preparing statement, file is not a database, file is not a database (code 26)
  Causing statement: SELECT * FROM probe
indexeddb afterOpen=false default=false uri-shim: correct key reopen [{n: 1}]
indexeddb afterOpen=false default=false uri-default-flag: SqliteException(1): while executing, Setting key failed. Encryption is not supported by the VFS., SQL logic error (code 1)
  Causing statement: PRAGMA key = "x'abababababababababababababababababababababababababababababababab'";, parameters: 
indexeddb afterOpen=false default=false argument-shim: cipher=[{chacha20: chacha20}] key + write accepted [{value: synthetic}]
indexeddb afterOpen=false default=false argument-shim: wrong key rejected: SqliteException(26): while preparing statement, file is not a database, file is not a database (code 26)
  Causing statement: SELECT * FROM probe
indexeddb afterOpen=false default=false argument-shim: correct key reopen [{n: 1}]
indexeddb afterOpen=false default=true plain: SqliteException(1): while executing, Setting key failed. Encryption is not supported by the VFS., SQL logic error (code 1)
  Causing statement: PRAGMA key = "x'abababababababababababababababababababababababababababababababab'";, parameters: 
indexeddb afterOpen=false default=true uri-direct: SqliteException(1): while executing, Setting key failed. Encryption is not supported by the VFS., SQL logic error (code 1)
  Causing statement: PRAGMA key = "x'abababababababababababababababababababababababababababababababab'";, parameters: 
indexeddb afterOpen=false default=true uri-shim: cipher=[{chacha20: chacha20}] key + write accepted [{value: synthetic}, {value: synthetic}]
indexeddb afterOpen=false default=true uri-shim: wrong key rejected: SqliteException(26): while preparing statement, file is not a database, file is not a database (code 26)
  Causing statement: SELECT * FROM probe
indexeddb afterOpen=false default=true uri-shim: correct key reopen [{n: 2}]
indexeddb afterOpen=false default=true uri-default-flag: SqliteException(1): while executing, Setting key failed. Encryption is not supported by the VFS., SQL logic error (code 1)
  Causing statement: PRAGMA key = "x'abababababababababababababababababababababababababababababababab'";, parameters: 
indexeddb afterOpen=false default=true argument-shim: cipher=[{chacha20: chacha20}] key + write accepted [{value: synthetic}, {value: synthetic}]
indexeddb afterOpen=false default=true argument-shim: wrong key rejected: SqliteException(26): while preparing statement, file is not a database, file is not a database (code 26)
  Causing statement: SELECT * FROM probe
indexeddb afterOpen=false default=true argument-shim: correct key reopen [{n: 2}]
indexeddb afterOpen=true default=false plain: SqliteException(1): while executing, Setting key failed. Encryption is not supported by the VFS., SQL logic error (code 1)
  Causing statement: PRAGMA key = "x'abababababababababababababababababababababababababababababababab'";, parameters: 
indexeddb afterOpen=true default=false uri-direct: SqliteException(1): while executing, Setting key failed. Encryption is not supported by the VFS., SQL logic error (code 1)
  Causing statement: PRAGMA key = "x'abababababababababababababababababababababababababababababababab'";, parameters: 
indexeddb afterOpen=true default=false uri-shim: cipher=[{chacha20: chacha20}] key + write accepted [{value: synthetic}, {value: synthetic}, {value: synthetic}]
indexeddb afterOpen=true default=false uri-shim: wrong key rejected: SqliteException(26): while preparing statement, file is not a database, file is not a database (code 26)
  Causing statement: SELECT * FROM probe
indexeddb afterOpen=true default=false uri-shim: correct key reopen [{n: 3}]
indexeddb afterOpen=true default=false uri-default-flag: SqliteException(1): while executing, Setting key failed. Encryption is not supported by the VFS., SQL logic error (code 1)
  Causing statement: PRAGMA key = "x'abababababababababababababababababababababababababababababababab'";, parameters: 
indexeddb afterOpen=true default=false argument-shim: cipher=[{chacha20: chacha20}] key + write accepted [{value: synthetic}, {value: synthetic}, {value: synthetic}]
indexeddb afterOpen=true default=false argument-shim: wrong key rejected: SqliteException(26): while preparing statement, file is not a database, file is not a database (code 26)
  Causing statement: SELECT * FROM probe
indexeddb afterOpen=true default=false argument-shim: correct key reopen [{n: 3}]
indexeddb afterOpen=true default=true plain: SqliteException(1): while executing, Setting key failed. Encryption is not supported by the VFS., SQL logic error (code 1)
  Causing statement: PRAGMA key = "x'abababababababababababababababababababababababababababababababab'";, parameters: 
indexeddb afterOpen=true default=true uri-direct: SqliteException(1): while executing, Setting key failed. Encryption is not supported by the VFS., SQL logic error (code 1)
  Causing statement: PRAGMA key = "x'abababababababababababababababababababababababababababababababab'";, parameters: 
indexeddb afterOpen=true default=true uri-shim: cipher=[{chacha20: chacha20}] key + write accepted [{value: synthetic}, {value: synthetic}, {value: synthetic}, {value: synthetic}]
indexeddb afterOpen=true default=true uri-shim: wrong key rejected: SqliteException(26): while preparing statement, file is not a database, file is not a database (code 26)
  Causing statement: SELECT * FROM probe
indexeddb afterOpen=true default=true uri-shim: correct key reopen [{n: 4}]
indexeddb afterOpen=true default=true uri-default-flag: SqliteException(1): while executing, Setting key failed. Encryption is not supported by the VFS., SQL logic error (code 1)
  Causing statement: PRAGMA key = "x'abababababababababababababababababababababababababababababababab'";, parameters: 
indexeddb afterOpen=true default=true argument-shim: cipher=[{chacha20: chacha20}] key + write accepted [{value: synthetic}, {value: synthetic}, {value: synthetic}, {value: synthetic}]
indexeddb afterOpen=true default=true argument-shim: wrong key rejected: SqliteException(26): while preparing statement, file is not a database, file is not a database (code 26)
  Causing statement: SELECT * FROM probe
indexeddb afterOpen=true default=true argument-shim: correct key reopen [{n: 4}]
opfs afterOpen=false default=false plain: SqliteException(1): while executing, Setting key failed. Encryption is not supported by the VFS., SQL logic error (code 1)
  Causing statement: PRAGMA key = "x'abababababababababababababababababababababababababababababababab'";, parameters: 
opfs afterOpen=false default=false uri-direct: SqliteException(1): while executing, Setting key failed. Encryption is not supported by the VFS., SQL logic error (code 1)
  Causing statement: PRAGMA key = "x'abababababababababababababababababababababababababababababababab'";, parameters: 
opfs afterOpen=false default=false uri-shim: cipher=[{chacha20: chacha20}] key + write accepted [{value: synthetic}]
opfs afterOpen=false default=false uri-shim: wrong key rejected: SqliteException(26): while preparing statement, file is not a database, file is not a database (code 26)
  Causing statement: SELECT * FROM probe
opfs afterOpen=false default=false uri-shim: correct key reopen [{n: 1}]
opfs afterOpen=false default=false uri-default-flag: SqliteException(1): while executing, Setting key failed. Encryption is not supported by the VFS., SQL logic error (code 1)
  Causing statement: PRAGMA key = "x'abababababababababababababababababababababababababababababababab'";, parameters: 
opfs afterOpen=false default=false argument-shim: cipher=[{chacha20: chacha20}] key + write accepted [{value: synthetic}, {value: synthetic}]
opfs afterOpen=false default=false argument-shim: wrong key rejected: SqliteException(26): while preparing statement, file is not a database, file is not a database (code 26)
  Causing statement: SELECT * FROM probe
opfs afterOpen=false default=false argument-shim: correct key reopen [{n: 2}]
opfs afterOpen=false default=true plain: SqliteException(1): while executing, Setting key failed. Encryption is not supported by the VFS., SQL logic error (code 1)
  Causing statement: PRAGMA key = "x'abababababababababababababababababababababababababababababababab'";, parameters: 
opfs afterOpen=false default=true uri-direct: SqliteException(1): while executing, Setting key failed. Encryption is not supported by the VFS., SQL logic error (code 1)
  Causing statement: PRAGMA key = "x'abababababababababababababababababababababababababababababababab'";, parameters: 
opfs afterOpen=false default=true uri-shim: cipher=[{chacha20: chacha20}] key + write accepted [{value: synthetic}, {value: synthetic}, {value: synthetic}]
opfs afterOpen=false default=true uri-shim: wrong key rejected: SqliteException(26): while preparing statement, file is not a database, file is not a database (code 26)
  Causing statement: SELECT * FROM probe
opfs afterOpen=false default=true uri-shim: correct key reopen [{n: 3}]
opfs afterOpen=false default=true uri-default-flag: SqliteException(1): while executing, Setting key failed. Encryption is not supported by the VFS., SQL logic error (code 1)
  Causing statement: PRAGMA key = "x'abababababababababababababababababababababababababababababababab'";, parameters: 
opfs afterOpen=false default=true argument-shim: cipher=[{chacha20: chacha20}] key + write accepted [{value: synthetic}, {value: synthetic}, {value: synthetic}, {value: synthetic}]
opfs afterOpen=false default=true argument-shim: wrong key rejected: SqliteException(26): while preparing statement, file is not a database, file is not a database (code 26)
  Causing statement: SELECT * FROM probe
opfs afterOpen=false default=true argument-shim: correct key reopen [{n: 4}]
opfs afterOpen=true default=false plain: SqliteException(1): while executing, Setting key failed. Encryption is not supported by the VFS., SQL logic error (code 1)
  Causing statement: PRAGMA key = "x'abababababababababababababababababababababababababababababababab'";, parameters: 
opfs afterOpen=true default=false uri-direct: SqliteException(1): while executing, Setting key failed. Encryption is not supported by the VFS., SQL logic error (code 1)
  Causing statement: PRAGMA key = "x'abababababababababababababababababababababababababababababababab'";, parameters: 
opfs afterOpen=true default=false uri-shim: cipher=[{chacha20: chacha20}] key + write accepted [{value: synthetic}, {value: synthetic}, {value: synthetic}, {value: synthetic}, {value: synthetic}]
opfs afterOpen=true default=false uri-shim: wrong key rejected: SqliteException(26): while preparing statement, file is not a database, file is not a database (code 26)
  Causing statement: SELECT * FROM probe
opfs afterOpen=true default=false uri-shim: correct key reopen [{n: 5}]
opfs afterOpen=true default=false uri-default-flag: SqliteException(1): while executing, Setting key failed. Encryption is not supported by the VFS., SQL logic error (code 1)
  Causing statement: PRAGMA key = "x'abababababababababababababababababababababababababababababababab'";, parameters: 
opfs afterOpen=true default=false argument-shim: cipher=[{chacha20: chacha20}] key + write accepted [{value: synthetic}, {value: synthetic}, {value: synthetic}, {value: synthetic}, {value: synthetic}, {value: synthetic}]
opfs afterOpen=true default=false argument-shim: wrong key rejected: SqliteException(26): while preparing statement, file is not a database, file is not a database (code 26)
  Causing statement: SELECT * FROM probe
opfs afterOpen=true default=false argument-shim: correct key reopen [{n: 6}]
opfs afterOpen=true default=true plain: SqliteException(1): while executing, Setting key failed. Encryption is not supported by the VFS., SQL logic error (code 1)
  Causing statement: PRAGMA key = "x'abababababababababababababababababababababababababababababababab'";, parameters: 
opfs afterOpen=true default=true uri-direct: SqliteException(1): while executing, Setting key failed. Encryption is not supported by the VFS., SQL logic error (code 1)
  Causing statement: PRAGMA key = "x'abababababababababababababababababababababababababababababababab'";, parameters: 
opfs afterOpen=true default=true uri-shim: cipher=[{chacha20: chacha20}] key + write accepted [{value: synthetic}, {value: synthetic}, {value: synthetic}, {value: synthetic}, {value: synthetic}, {value: synthetic}, {value: synthetic}]
opfs afterOpen=true default=true uri-shim: wrong key rejected: SqliteException(26): while preparing statement, file is not a database, file is not a database (code 26)
  Causing statement: SELECT * FROM probe
opfs afterOpen=true default=true uri-shim: correct key reopen [{n: 7}]
opfs afterOpen=true default=true uri-default-flag: SqliteException(1): while executing, Setting key failed. Encryption is not supported by the VFS., SQL logic error (code 1)
  Causing statement: PRAGMA key = "x'abababababababababababababababababababababababababababababababab'";, parameters: 
opfs afterOpen=true default=true argument-shim: cipher=[{chacha20: chacha20}] key + write accepted [{value: synthetic}, {value: synthetic}, {value: synthetic}, {value: synthetic}, {value: synthetic}, {value: synthetic}, {value: synthetic}, {value: synthetic}]
opfs afterOpen=true default=true argument-shim: wrong key rejected: SqliteException(26): while preparing statement, file is not a database, file is not a database (code 26)
  Causing statement: SELECT * FROM probe
opfs afterOpen=true default=true argument-shim: correct key reopen [{n: 8}]
```

### Attempt 3: real app opener, before implementation

```text
/Users/aedwon/Documents/Projects/Pantas-wt-pwa-foundation-r1/build/verify_web_database.js:2850
      throw error;
      ^

UnimplementedError: B3 encrypted study database is blocked: the locked sqlite3 3.5.1 wasm rejects encryption on the Dart VFS. See B3-encrypted-web-db.md.
    at Object.wrapException (/Users/aedwon/Documents/Projects/Pantas-wt-pwa-foundation-r1/build/verify_web_database.js:405:47)
    at /Users/aedwon/Documents/Projects/Pantas-wt-pwa-foundation-r1/build/verify_web_database.js:2990:23
    at _wrapJsFunctionForAsync_closure.$protected (/Users/aedwon/Documents/Projects/Pantas-wt-pwa-foundation-r1/build/verify_web_database.js:2457:15)
    at _wrapJsFunctionForAsync_closure.call$2 (/Users/aedwon/Documents/Projects/Pantas-wt-pwa-foundation-r1/build/verify_web_database.js:3418:12)
    at Object._asyncStartSync (/Users/aedwon/Documents/Projects/Pantas-wt-pwa-foundation-r1/build/verify_web_database.js:2402:20)
    at Object.openEncryptedDatabase (/Users/aedwon/Documents/Projects/Pantas-wt-pwa-foundation-r1/build/verify_web_database.js:2995:16)
    at /Users/aedwon/Documents/Projects/Pantas-wt-pwa-foundation-r1/build/verify_web_database.js:3011:38
    at _wrapJsFunctionForAsync_closure.$protected (/Users/aedwon/Documents/Projects/Pantas-wt-pwa-foundation-r1/build/verify_web_database.js:2457:15)
    at _wrapJsFunctionForAsync_closure.call$2 (/Users/aedwon/Documents/Projects/Pantas-wt-pwa-foundation-r1/build/verify_web_database.js:3418:12)
    at Object._asyncStartSync (/Users/aedwon/Documents/Projects/Pantas-wt-pwa-foundation-r1/build/verify_web_database.js:2402:20) {
  dartException: <ref *1> UnimplementedError {
    message: 'B3 encrypted study database is blocked: the locked sqlite3 3.5.1 wasm rejects encryption on the Dart VFS. See B3-encrypted-web-db.md.',
    '$thrownJsError': <ref *2> UnimplementedError: B3 encrypted study database is blocked: the locked sqlite3 3.5.1 wasm rejects encryption on the Dart VFS. See B3-encrypted-web-db.md.
        at Object.wrapException (/Users/aedwon/Documents/Projects/Pantas-wt-pwa-foundation-r1/build/verify_web_database.js:405:47)
        at /Users/aedwon/Documents/Projects/Pantas-wt-pwa-foundation-r1/build/verify_web_database.js:2990:23
        at _wrapJsFunctionForAsync_closure.$protected (/Users/aedwon/Documents/Projects/Pantas-wt-pwa-foundation-r1/build/verify_web_database.js:2457:15)
        at _wrapJsFunctionForAsync_closure.call$2 (/Users/aedwon/Documents/Projects/Pantas-wt-pwa-foundation-r1/build/verify_web_database.js:3418:12)
        at Object._asyncStartSync (/Users/aedwon/Documents/Projects/Pantas-wt-pwa-foundation-r1/build/verify_web_database.js:2402:20)
        at Object.openEncryptedDatabase (/Users/aedwon/Documents/Projects/Pantas-wt-pwa-foundation-r1/build/verify_web_database.js:2995:16)
        at /Users/aedwon/Documents/Projects/Pantas-wt-pwa-foundation-r1/build/verify_web_database.js:3011:38
        at _wrapJsFunctionForAsync_closure.$protected (/Users/aedwon/Documents/Projects/Pantas-wt-pwa-foundation-r1/build/verify_web_database.js:2457:15)
        at _wrapJsFunctionForAsync_closure.call$2 (/Users/aedwon/Documents/Projects/Pantas-wt-pwa-foundation-r1/build/verify_web_database.js:3418:12)
        at Object._asyncStartSync (/Users/aedwon/Documents/Projects/Pantas-wt-pwa-foundation-r1/build/verify_web_database.js:2402:20) {
      dartException: [Circular *1],
      '$cachedTrace': _StackTrace {
        _exception: [Circular *2],
        _trace: 'UnimplementedError: B3 encrypted study database is blocked: the locked sqlite3 3.5.1 wasm rejects encryption on the Dart VFS. See B3-encrypted-web-db.md.\n' +
          '    at Object.wrapException (/Users/aedwon/Documents/Projects/Pantas-wt-pwa-foundation-r1/build/verify_web_database.js:405:47)\n' +
          '    at /Users/aedwon/Documents/Projects/Pantas-wt-pwa-foundation-r1/build/verify_web_database.js:2990:23\n' +
          '    at _wrapJsFunctionForAsync_closure.$protected (/Users/aedwon/Documents/Projects/Pantas-wt-pwa-foundation-r1/build/verify_web_database.js:2457:15)\n' +
          '    at _wrapJsFunctionForAsync_closure.call$2 (/Users/aedwon/Documents/Projects/Pantas-wt-pwa-foundation-r1/build/verify_web_database.js:3418:12)\n' +
          '    at Object._asyncStartSync (/Users/aedwon/Documents/Projects/Pantas-wt-pwa-foundation-r1/build/verify_web_database.js:2402:20)\n' +
          '    at Object.openEncryptedDatabase (/Users/aedwon/Documents/Projects/Pantas-wt-pwa-foundation-r1/build/verify_web_database.js:2995:16)\n' +
          '    at /Users/aedwon/Documents/Projects/Pantas-wt-pwa-foundation-r1/build/verify_web_database.js:3011:38\n' +
          '    at _wrapJsFunctionForAsync_closure.$protected (/Users/aedwon/Documents/Projects/Pantas-wt-pwa-foundation-r1/build/verify_web_database.js:2457:15)\n' +
          '    at _wrapJsFunctionForAsync_closure.call$2 (/Users/aedwon/Documents/Projects/Pantas-wt-pwa-foundation-r1/build/verify_web_database.js:3418:12)\n' +
          '    at Object._asyncStartSync (/Users/aedwon/Documents/Projects/Pantas-wt-pwa-foundation-r1/build/verify_web_database.js:2402:20)'
      }
    }
  }
}

Node.js v26.10.0
```

### Attempt 4: real app opener, final

```text
PASS: ciphertext at rest, non-extractable wrapping key, key and database tamper refusal, recovery;
PASS: schema, write, owner exclusion, close, encrypted reopen
```

The app verification creates its actual schema, writes synthetic study data, closes the entire VFS and opens a new one, and reads the persisted result. It checks owner exclusion, ciphertext at rest, a non-extractable wrapping key, wrapped-key tampering, database tampering, and recovery after restoring synthetic records.

### Attempt 5: ordinary SQLite substituted for the encrypted wasm

Expected nonzero exit. No plaintext database is accepted.

```text
/Users/aedwon/Documents/Projects/Pantas-wt-pwa-foundation-r1/build/verify_web_database.js:5400
      throw error;
      ^

SqliteException(1): while opening the database, no such vfs: multipleciphers-indexeddb, SQL logic error (code 1)
    at Object.wrapException (/Users/aedwon/Documents/Projects/Pantas-wt-pwa-foundation-r1/build/verify_web_database.js:922:47)
    at WasmSqlite3.open$5$mode$mutex$uri$vfs (/Users/aedwon/Documents/Projects/Pantas-wt-pwa-foundation-r1/build/verify_web_database.js:21113:17)
    at _WasmDelegate.openDatabase$0 (/Users/aedwon/Documents/Projects/Pantas-wt-pwa-foundation-r1/build/verify_web_database.js:18294:23)
    at /Users/aedwon/Documents/Projects/Pantas-wt-pwa-foundation-r1/build/verify_web_database.js:18068:55
    at _wrapJsFunctionForAsync_closure.$protected (/Users/aedwon/Documents/Projects/Pantas-wt-pwa-foundation-r1/build/verify_web_database.js:3438:15)
    at _wrapJsFunctionForAsync_closure.call$2 (/Users/aedwon/Documents/Projects/Pantas-wt-pwa-foundation-r1/build/verify_web_database.js:10823:12)
    at Object._asyncStartSync (/Users/aedwon/Documents/Projects/Pantas-wt-pwa-foundation-r1/build/verify_web_database.js:3402:20)
    at _WasmDelegate.open$1 (/Users/aedwon/Documents/Projects/Pantas-wt-pwa-foundation-r1/build/verify_web_database.js:18105:16)
    at /Users/aedwon/Documents/Projects/Pantas-wt-pwa-foundation-r1/build/verify_web_database.js:17190:39
    at _wrapJsFunctionForAsync_closure.$protected (/Users/aedwon/Documents/Projects/Pantas-wt-pwa-foundation-r1/build/verify_web_database.js:3438:15) {
  dartException: SqliteException {
    message: 'no such vfs: multipleciphers-indexeddb',
    explanation: 'SQL logic error (code 1)',
    extendedResultCode: 1,
    offset: null,
    operation: 'opening the database',
    causingStatement: null,
    parametersToStatement: null
  }
}

Node.js v26.10.0
```

Harness corrections during the work: the first at-rest inspection treated ArrayBuffer blocks as Blob and failed with `TypeError: b.arrayBuffer is not a function`. It now handles both. Adding document.baseURI required the Node document stub to include currentScript; the final completion guard rejects a skipped main. An npm cache permission failure was resolved using a task-local cache. These were probe-host failures, not encryption failures.

## Delivered app path and limits

`database_opener_web.dart` uses the supported Drift WasmDatabase constructor with IndexedDbFileSystem and explicit flushes. A CommonSqlite3 adapter selects the upstream shim through the public VFS argument, since the Drift constructor does not expose one. The engine stays upstream. Every write and transaction completion uses Drift's existing IndexedDB flush behavior.

The opener generates a random 32-byte key using Web Crypto. A non-extractable AES-GCM key encrypts that key. IndexedDB stores the CryptoKey, nonce, and wrapped ciphertext. It never stores the raw database key. The key record commits before the database is opened. Damaged records fail closed. The code names the limit: wrapping protects copied browser files, not code running on the site.

Web Locks hold one owner for the entire cached IndexedDB VFS lifetime. A second active tab is refused, and close releases the lock. Browsers without the necessary APIs fail closed. This is a documented foundation limit, not a claim of multi-tab support. Main-thread IndexedDB was selected because it is the verified supported VFS path. OPFS and shared-worker integration are not delivered. The standard Drift worker remains shipped for the planned content path.

## Content stop condition

The active bootstrap calls ensureProtectedContentInstalled before opening content. Its verifier authenticates the exact manifest with Ed25519, validates production and sequence windows, requires a pinned 32-byte bootstrap key, and checks the payload SHA-256. The native installer writes the encrypted payload to pending, opens SQLCipher with that bootstrap key, validates the corpus, and rekeys to a per-install key before promotion. Startup gets the bootstrap key from the PANTAS_CONTENT_BOOTSTRAP_KEY_V1_B64 compile-time define.

The bundled content is not a plaintext lesson database. A signature does not decrypt it. Shipping the bootstrap key in a compiled web app would expose it to site code. The user explicitly instructed this run to stop in that case. Web content opening and seed installation remain stopped. No initializeDatabase seed import or version skip is delivered. No secret was read, injected, or shipped. Native installation, opener, verifier, manifest, and signature checks remain unchanged. The seed and signature were copied by the lead; this run did not regenerate them.

## Remaining acceptance

Full Flutter results and artifact identities are in B2-B3-verification.md and its raw command logs. No real browser, phone, staging sign-in, OPFS durability, independent security review, or lead acceptance is claimed. Google sign-in and Firebase placeholders remain as directed. Shared status is for the lead to update.

Full-suite verification was interrupted after 40:29 with 3,969 passes, one corrected boundary failure, and one unfinished roadmap property test. It did not pass. See B2-B3-verification.md for verbatim failures and cancellation diagnostics.
