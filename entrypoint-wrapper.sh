#!/usr/bin/env bash
# Ensure /opt/data/gh-config exists and is owned by hermes before the upstream
# entrypoint runs. This makes `gh auth login` work out-of-the-box on a fresh
# volume, since GH_CONFIG_DIR points here.
set -e

if [ "$(id -u)" = "0" ]; then
  HERMES_UID_VAL="${HERMES_UID:-10000}"
  HERMES_GID_VAL="${HERMES_GID:-10000}"
  mkdir -p /opt/data/gh-config
  chown -R "${HERMES_UID_VAL}:${HERMES_GID_VAL}" /opt/data/gh-config 2>/dev/null || true
  chmod 700 /opt/data/gh-config 2>/dev/null || true
fi

exec /opt/hermes/docker/entrypoint.sh "$@"
