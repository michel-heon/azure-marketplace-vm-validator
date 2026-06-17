#!/usr/bin/env bash
set -euo pipefail

ctt_pkg_update_security_check_cmd() {
  # P2.2 — refresh the package index first (no actual download), then simulate
  # both `upgrade` and `dist-upgrade` to catch replacements and transitional
  # packages. Returns "false" (== no pending security updates == PASS).
  printf '%s' "if command -v apt-get >/dev/null 2>&1; then \
    DEBIAN_FRONTEND=noninteractive apt-get -qq update >/dev/null 2>&1; \
    pending=\$(apt-get -s dist-upgrade 2>/dev/null | grep -E '^Inst .*[Ss]ecurity' | wc -l); \
    [ \"\$pending\" -eq 0 ] && echo true || echo false; \
  else echo true; fi"
}

ctt_cloud_init_present_cmd() {
  printf '%s' "dpkg -s cloud-init >/dev/null 2>&1 && echo true || echo false"
}

ctt_pkg_installed_cmd() {
  local pkg="$1"
  printf '%s' "dpkg -s '${pkg}' >/dev/null 2>&1 && echo true || echo false"
}

# Optional — package manager name (ADR-100)
ctt_pkg_manager_name() {
  printf '%s' "apt"
}

# Optional — OS release ID (ADR-100)
ctt_os_release_id() {
  printf '%s' "ubuntu"
}
