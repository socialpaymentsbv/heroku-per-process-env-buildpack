# Heroku Per-Process Environment Buildpack

Set different environment variable values per process type *and* dyno index without redeploying. This buildpack inspects the `$DYNO` name every time a dyno boots and transparently re-exports unprefixed variables derived from prefixed ones.

## Installation

Make this the first buildpack on your app so it can inject variables before later buildpacks run:

   ```fish
   heroku buildpacks:add --index 1 https://github.com/your-org/heroku-per-process-env-buildpack
   ```


## Configuring variables

Use uppercase process type prefixes that match the portion before the dot in `$DYNO`.

| Dyno | Type prefix | Example per-type | Example per-index |
| --- | --- | --- | --- |
| `web.1` | `WEB` | `WEB__DATABASE_URL` | `WEB_1__DATABASE_URL` |
| `worker.3` | `WORKER` | `WORKER__REDIS_URL` | `WORKER_3__REDIS_URL` |
| `run.12345` | `RUN` | `RUN__FEATURE_FLAG` | `RUN_12345__FEATURE_FLAG` |

Set values with `heroku config:set` as usual:

```fish
heroku config:set WEB__API_TOKEN=shared-token WEB_2__API_TOKEN=blue-dyno-token
```

When `web.2` starts it receives `API_TOKEN=blue-dyno-token`. Other `web.*` dynos read `API_TOKEN=shared-token`.

## Contributing

1. Fork, branch, and modify the runtime script in `lib/per-process-env.sh`.
2. Run the tests/*.
3. Open a PR with details about new scenarios or edge cases.
