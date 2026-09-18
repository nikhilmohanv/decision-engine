#!/bin/sh
# Apply this repo's diesel migrations (migrations_pg), then
# start Decision Engine. Each migration runs once, recorded in diesel's own
# __diesel_schema_migrations table so a later diesel CLI run agrees with us.
set -eu

# Render assigns the port via PORT (10000 by default) and routes the service's
# internal address there; upstream only reads [server].port from config, so map
# it across. Falls back to the config default when PORT is unset.
export DECISION_ENGINE__SERVER__PORT="${PORT:-8080}"

export PGHOST="$DECISION_ENGINE__PG_DATABASE__PG_HOST"
export PGPORT="${DECISION_ENGINE__PG_DATABASE__PG_PORT:-5432}"
export PGUSER="$DECISION_ENGINE__PG_DATABASE__PG_USERNAME"
export PGPASSWORD="$DECISION_ENGINE__PG_DATABASE__PG_PASSWORD"
export PGDATABASE="$DECISION_ENGINE__PG_DATABASE__PG_DBNAME"

psql -v ON_ERROR_STOP=1 -q -c "CREATE TABLE IF NOT EXISTS __diesel_schema_migrations (version VARCHAR(50) PRIMARY KEY NOT NULL, run_on TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP)"

for dir in $(ls -1 /local/migrations_pg | sort); do
  version=$(echo "$dir" | cut -d_ -f1 | tr -d '-')
  done_already=$(psql -tAq -c "SELECT 1 FROM __diesel_schema_migrations WHERE version = '$version'")
  if [ "$done_already" = "1" ]; then
    continue
  fi
  echo "[decision-engine] applying migration $dir"
  psql -v ON_ERROR_STOP=1 -q -1 \
    -f "/local/migrations_pg/$dir/up.sql" \
    -c "INSERT INTO __diesel_schema_migrations (version) VALUES ('$version')"
done

exec ./open_router
