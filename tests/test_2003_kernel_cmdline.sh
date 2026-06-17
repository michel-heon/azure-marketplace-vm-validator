#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/_common.sh
source "$ROOT_DIR/lib/_common.sh"
ctt_load_distro_adapter

ctt_remote_check_true "Kernel cmdline contains console=ttyS0" "grep -q "console=ttyS0" /proc/cmdline && echo true || echo false"
