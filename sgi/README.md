# SGI deployment of Decision Engine

Fork of [juspay/decision-engine](https://github.com/juspay/decision-engine) used by
Startup Grants India for payment-gateway routing only (no card data, no vault).

- Branch `sgi` is pinned to upstream release `v1.4.35` (commit `f2b4439`).
- `sgi/Dockerfile` adds our config (analytics off; secrets from
  `DECISION_ENGINE__*` env vars) and `sgi/start.sh`, which applies
  `migrations_pg` once (tracked in `__diesel_schema_migrations`) and starts the API.
- `.github/workflows/sgi-image.yml` publishes
  `ghcr.io/nikhilmohanv/decision-engine:sgi-v1.4.35` (plus a `sgi-<sha>` tag) on
  every push to `sgi`. Render runs it as a private service.
- Upstream workflows are disabled in this fork.

## Upgrading upstream
1. Fetch the new upstream tag, merge it into `sgi`.
2. Bump `BASE_IMAGE` in `sgi/Dockerfile` and `UPSTREAM_VERSION` in the workflow.
3. Diff `config/docker-configuration.toml` against `sgi/config.toml` for new sections.
4. Push, then point the Render service at the new tag.
