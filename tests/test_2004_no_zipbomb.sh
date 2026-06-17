#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/_common.sh
source "$ROOT_DIR/lib/_common.sh"
ctt_load_distro_adapter

# DRIFT-002 (2026-06-15): search the entire filesystem for the known artifact
# name "zip-bomb.zip". -xdev prevents crossing mount boundaries (tmpfs, proc,
# sysfs, NFS…), making the scan fast and bounded.
ctt_remote_check_false "No zip-bomb.zip artifact anywhere on the filesystem" \
  "find / -xdev -type f -name 'zip-bomb.zip' 2>/dev/null | grep -q . && echo true || echo false"
