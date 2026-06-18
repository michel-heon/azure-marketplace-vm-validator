#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/_common.sh
source "$ROOT_DIR/lib/_common.sh"
ctt_load_distro_adapter

# Policy 200.6.x — Required systemd services must be active.
# Caller project sets CTT_REQUIRED_SERVICES (space-separated list).
# If the variable is unset or empty, the test is skipped with a WARN.
if [[ -z "${CTT_REQUIRED_SERVICES:-}" ]]; then
  ctt_warn "test_2006_required_services: CTT_REQUIRED_SERVICES not set — test skipped"
  exit 0
fi

all_active=true
for svc in $CTT_REQUIRED_SERVICES; do
  ctt_remote_check_true "Service '${svc}' is active" \
    "systemctl is-active --quiet '${svc}' && echo true || echo false" || all_active=false
done

"$all_active"
