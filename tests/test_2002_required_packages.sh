#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/_common.sh
source "$ROOT_DIR/lib/_common.sh"
ctt_load_distro_adapter

# Policy 200.2.x — Required packages must be installed on the image.
# Caller project sets CTT_REQUIRED_PACKAGES (space-separated list).
# If the variable is unset or empty, the test is skipped with a WARN.
if [[ -z "${CTT_REQUIRED_PACKAGES:-}" ]]; then
  ctt_warn "test_2002_required_packages: CTT_REQUIRED_PACKAGES not set — test skipped"
  exit 0
fi

all_present=true
for pkg in $CTT_REQUIRED_PACKAGES; do
  ctt_remote_check_true "Package '${pkg}' is installed" \
    "$(ctt_pkg_installed_cmd "$pkg")" || all_present=false
done

"$all_present"
