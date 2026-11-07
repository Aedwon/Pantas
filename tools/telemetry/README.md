# Telemetry readout

Prints how long web startup steps and server functions take, and which web errors
happen, from the reports in Cloud Logging.

```bash
node tools/telemetry/report.mjs --project pantas-prod --hours 24
node tools/telemetry/report.mjs --project pantas-prod --hours 24 --build 1293236267-5bbf79dc07b4 --visit return
```

- Needs the `gcloud` CLI signed in with permission to read logs on the project.
- `--hours` defaults to 24 and is at most 720. Logs are kept 30 days.
- `--build` and `--visit` (`first`, `return`, `after_deploy`) filter the client reports only.
  Server function lines carry no build or visit, so they always cover the whole period.
- Output: per client timing name (count, p50, p90, max in ms), per function (count, p50, p90,
  cold share, error count), and errors grouped by type and first stack line.
- Percentiles use the nearest rank. A timing with few reports is a rough guide only.

The reports come from the `reportClientTelemetry` callable (log kind `client_telemetry`) and
from the timing wrapper on every callable (log kind `fn_timing`). Neither holds a user id.

Test: `node --test tools/telemetry/report.test.mjs`. The tests use fixtures and never run `gcloud`.
