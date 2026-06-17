#!/usr/bin/env bash
set -euo pipefail

ctt_pkg_update_security_check_cmd() {
  printf '%s' "if command -v apt-get >/dev/null 2>&1; then apt-get -s upgrade | grep -Eq '^Inst .*Security' && echo false || echo true; else echo true; fi"
}

ctt_cloud_init_present_cmd() {
  printf '%s' "dpkg -s cloud-init >/dev/null 2>&1 && echo true || echo false"
}
