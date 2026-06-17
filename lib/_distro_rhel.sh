#!/usr/bin/env bash
set -euo pipefail

# Distro adapter — RHEL / CentOS Stream / Rocky Linux / AlmaLinux
# Implements the mandatory adapter contract defined in ADR-100.
#
# Supported distros (CTT_DISTRO=rhel):
#   RHEL 8, RHEL 9
#   CentOS Stream 8, CentOS Stream 9
#   Rocky Linux 8, Rocky Linux 9
#   AlmaLinux 8, AlmaLinux 9

ctt_pkg_update_security_check_cmd() {
  # Refresh DNF metadata, then check for security advisories.
  # `dnf updateinfo list updates security` lists packages with a pending
  # security advisory; empty output == no pending security updates.
  printf '%s' "dnf -q makecache --refresh >/dev/null 2>&1; \
    pending=\$(dnf updateinfo list updates security 2>/dev/null | grep -cE '^[A-Z]+-[0-9]' || true); \
    [ \"\$pending\" -eq 0 ] && echo true || echo false"
}

ctt_cloud_init_present_cmd() {
  printf '%s' "rpm -q cloud-init >/dev/null 2>&1 && echo true || echo false"
}

ctt_pkg_installed_cmd() {
  local pkg="$1"
  printf '%s' "rpm -q '${pkg}' >/dev/null 2>&1 && echo true || echo false"
}

# Optional — package manager name
ctt_pkg_manager_name() {
  printf '%s' "dnf"
}

# Optional — OS release ID
ctt_os_release_id() {
  printf '%s' "rhel"
}
