#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/_common.sh
source "$ROOT_DIR/lib/_common.sh"
ctt_load_distro_adapter

# Policy 200.5.8 — No packages with known security vulnerabilities installed.
# Generic equivalent of DRIFT-001 (USN-7823-1, USN-8169-1 …).
#
# CTT_VULNERABLE_PACKAGES — optional, space-separated list of package names to
# check explicitly (e.g. "ffmpeg lua5.4 redis").  When set, each listed package
# is tested via `apt-cache policy` to verify the installed version is not
# superseded by a security-fixed version in the Ubuntu security pocket.
# When unset, the test falls back to the generic `apt-get -s dist-upgrade`
# scan already performed by test_2005_no_pending_security_updates.sh and emits
# a WARN (not FAIL) to avoid double-counting.
if [[ -z "${CTT_VULNERABLE_PACKAGES:-}" ]]; then
  ctt_warn "test_2005_no_vulnerable_packages: CTT_VULNERABLE_PACKAGES not set — using generic security-update check"
  ctt_remote_check_true "No packages with pending security fixes (generic)" \
    "$(ctt_pkg_update_security_check_cmd)"
  exit "$?"
fi

all_ok=true
for pkg in $CTT_VULNERABLE_PACKAGES; do
  # Check: installed version == candidate from security pocket (no newer available)
  ctt_remote_check_false "No pending security fix for package '${pkg}'" \
    "inst=\$(apt-cache policy '${pkg}' 2>/dev/null | awk '/Installed:/ {print \$2}'); \
     cand=\$(apt-cache policy '${pkg}' 2>/dev/null | awk '/Candidate:/ {print \$2}'); \
     [ \"\$inst\" != \"(none)\" ] && [ \"\$inst\" != \"\$cand\" ] && echo true || echo false" || all_ok=false
done

"$all_ok"
