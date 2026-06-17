#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/_common.sh
source "$ROOT_DIR/lib/_common.sh"
ctt_load_distro_adapter

ctt_remote_check_false "No empty shadow passwords" "awk -F: '\$2==""{found=1} END{if(found) print "true"; else print "false"}' /etc/shadow"
