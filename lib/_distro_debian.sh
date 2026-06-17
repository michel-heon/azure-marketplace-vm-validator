#!/usr/bin/env bash
set -euo pipefail

# Distro adapter — Debian
# Implements the mandatory adapter contract defined in ADR-100.
#
# Supported distros (CTT_DISTRO=debian):
#   Debian 11 (Bullseye)
#   Debian 12 (Bookworm)
#
# Note: Debian does not include Ubuntu Extended Security Maintenance (ESM).
# Security updates come directly from security.debian.org.

ctt_pkg_update_security_check_cmd() {
  # Refresh apt index, then simulate dist-upgrade looking for packages from
  # the security suite (origin: Debian, archive: *-security).
  printf '%s' "if command -v apt-get >/dev/null 2>&1; then \
    DEBIAN_FRONTEND=noninteractive apt-get -qq update >/dev/null 2>&1; \
    pending=\$(apt-get -s dist-upgrade 2>/dev/null | awk '/^Inst / { for(i=1;i<=NF;i++) if (\$i ~ /security/) { found=1 } } END { print (found ? 1 : 0) }'); \
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

# Optional — package manager name
ctt_pkg_manager_name() {
  printf '%s' "apt"
}

# Optional — OS release ID
ctt_os_release_id() {
  printf '%s' "debian"
}
