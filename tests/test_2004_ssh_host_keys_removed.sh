#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/_common.sh
source "$ROOT_DIR/lib/_common.sh"
ctt_load_distro_adapter

ctt_remote_check_false "Provisioning artifacts: SSH host keys removed" "ls /etc/ssh/ssh_host_*_key >/dev/null 2>&1 && echo true || echo false"
