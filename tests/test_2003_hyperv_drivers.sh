#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/_common.sh
source "$ROOT_DIR/lib/_common.sh"
ctt_load_distro_adapter

ctt_remote_check_true "Hyper-V drivers hv_netvsc + hv_storvsc are loaded" "lsmod | grep -q ^hv_netvsc && lsmod | grep -q ^hv_storvsc && echo true || echo false"
