# Grafana Alloy agent (OpenLMIS core environments)

One Alloy agent per environment host. It collects host, container and app
metrics plus container logs and the nginx log files, and pushes them to the
central [soldevelo-monitoring](https://github.com/SolDevelo/soldevelo-monitoring)
stack at `olmis-monitoring.soldevelo.com`. Unrelated to the Jenkins
InfluxDB/Grafana setup in the parent directory.

It runs as its own compose project (`soldevelo-monitoring-agents`), so app
deploys do not touch it.

## Files

| File | What |
|---|---|
| `config.alloy` | The package agent config, **vendored** at the tag in `PACKAGE_VERSION`. Never edit it here. |
| `openlmis.alloy` | OpenLMIS additions: nginx access/error logs from the `nginx-log` volume. |
| `sync-from-package.sh` | Re-copies `config.alloy` for `PACKAGE_VERSION`; `--check` reports drift. |
| `deploy_alloy.sh` | Builds the image on the env's Docker daemon and starts the agent. |
| `.env.example` | The variables. Real values: `<env>-alloy.env` in `openlmis-config`. |

Upgrade: bump `PACKAGE_VERSION`, run `./sync-from-package.sh`, read the diff and
the package CHANGELOG, commit, deploy.

## Deploy

Jenkins job `OpenLMIS-monitoring-alloy-deploy-to-<env>`, manual. It checks out
this repo and `openlmis-config` (into `.deployment-config/`) and runs
`monitoring/alloy/deploy_alloy.sh <env>` from the workspace root, where `<env>`
names both `<env>-alloy.env` and `<env>-certs`.

## Scraping apps

The agent scrapes containers labelled `monitoring.scrape: "true"`, at
`monitoring.port` + `monitoring.path`, named by `monitoring.service` (see
`deployment/uat_env/docker-compose.yml`). Labels apply when the app containers
are recreated, i.e. on the next app deploy.

## Notes

- `network_mode: host`, not the app network: the app deploy's
  `docker compose down` cannot remove `<env>_default` while a foreign container
  is attached to it. Container IPs on every bridge are reachable from the host.
- `COMPOSE_PROJECT_NAME` must stay `soldevelo-monitoring-agents`: `config.alloy`
  drops the agent's own logs by that project name.
- Labels: `app=openlmis`, `deployment=core`, `environment` from the monitoring
  enum — Test=`staging`, UAT=`uat`, Demo=`prod`.
