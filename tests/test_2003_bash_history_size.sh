#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/_common.sh
source "$ROOT_DIR/lib/_common.sh"
ctt_load_distro_adapter

ctt_remote_check_numeric_lte "bash history file total size <= 1024 bytes" "total=0; for f in /root/.bash_history /home/*/.bash_history; do [ -f \"\$f\" ] && total=\$((total + \$(wc -c < \"\$f\"))); done; echo \"\$total\"" 1024
